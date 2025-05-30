# Copyright 2019 Battelle Memorial Institute; see the LICENSE file.

#' module_aglu_L100.FAO_SUA_connection
#'
#' Pull and further process SUA data needed
#'
#' @param command API command to execute
#' @param ... other optional parameters, depending on command
#' @return Depends on \code{command}: either a vector of required inputs, a vector of output names, or (if
#'   \code{command} is "MAKE") all the generated outputs: \code{FAO_SUA_APE_balance}
#' @details Pull and further process SUA data needed. Calculate moving average if needed.
#' @importFrom assertthat assert_that
#' @importFrom dplyr bind_rows filter if_else inner_join left_join mutate rename select
#' @importFrom tidyr  complete drop_na gather nesting spread replace_na
#' @importFrom tibble tibble
#' @author XZ 2022
module_aglu_L100.FAO_SUA_connection <- function(command, ...) {

  MODULE_INPUTS <-
    c(FILE = "common/GCAM_region_names",
      FILE = "aglu/FAO/FAO_ag_items_PRODSTAT",
      FILE = "aglu/FAO/FAO_an_items_PRODSTAT",
      FILE = "aglu/A_agStorageSector",
      "GCAM_AgLU_SUA_APE_1973_2019",
      "FAO_AgProd_Kt_All",
      "FAO_AgArea_Kha_All",
      "FAO_Food_Macronutrient_All_2010_2019",
      "FAO_Food_MacronutrientRate_2010_2019_MaxValue")

  MODULE_OUTPUTS <-
    c("L100.FAO_SUA_APE_balance",
      "L100.FAO_ag_HA_ha",
      "L100.FAO_ag_Prod_t",
      "L100.FAO_PRODSTAT_TO_DOWNSCAL",
      "L101.an_Prod_Mt_R_C_Y",
      "L101.an_Prod_Mt_ctry_C_Y",
      "L101.ag_Food_Mt_R_C_Y",
      "L101.an_Food_Mt_R_C_Y",
      "L101.CropMeat_Food_Pcal_R_C_Y",
      "L101.ag_Feed_Mt_R_C_Y",
      "L101.GrossTrade_Mt_R_C_Y",
      "L101.ag_Storage_Mt_R_C_Y")

  if(command == driver.DECLARE_INPUTS) {
    return(MODULE_INPUTS)
  } else if(command == driver.DECLARE_OUTPUTS) {
    return(MODULE_OUTPUTS)
  } else if(command == driver.MAKE) {

    year <- value <- Year <- Value <- FAO_country <- iso <- NULL    # silence package check.

    all_data <- list(...)[[1]]

    # Load required inputs ----

    get_data_list(all_data, MODULE_INPUTS, strip_attributes = TRUE)



    # Key sets and mappings ----
    # Note that fodder crops are included in COMM_CROP though SUA did not have them;
    COMM_CROP <- FAO_ag_items_PRODSTAT %>% filter(!is.na(GCAM_commodity)) %>% distinct(GCAM_commodity) %>% pull
    COMM_MEAT <- FAO_an_items_PRODSTAT %>% filter(!is.na(GCAM_commodity)) %>% distinct(GCAM_commodity) %>% pull
    COMM_STORAGE <- A_agStorageSector %>% filter(storage_model == TRUE) %>% distinct(GCAM_commodity) %>% pull

    # assert that COMM_STORAGE commodities exist
    assert_that(all(COMM_STORAGE %in% c(COMM_CROP, COMM_MEAT)), msg = "Storage commodities do not all exist in data")



    # 0. Before 5-year average make sure data is consistent across periods ----
    # 2010 onward there is opening & closing stocks
    # Before 2010, only stock variation is available
    # Need to adjust negative stock where applicable due to the data connection
    # In most cases, adjustments are only needed in years before 2010 (won't affect base year mean)

    # Step_0.1 Fill in opening and closing stock using base year stock and variations
    GCAM_AgLU_SUA_APE_1973_2019 %>%
      spread(element, value) %>%
      group_by(GCAM_commodity, region) %>%
      arrange(-year) %>%
      mutate(CumStockVar = cumsum(`Stock Variation`),
             BaseYearClosingStock  = first(`Closing stocks`),
             OpenStock = BaseYearClosingStock - CumStockVar,
             CloseStock = OpenStock +`Stock Variation`) %>%
      ungroup ->
      GCAM_AgLU_SUA_APE_1973_2019_StockAdj1


    # Step_0.2 Deal with negative storage
    # Assumption here is simply to set stock variation to zero when stock is zero
    # and recalculate all
    # GCAM base year data won't be affected since data after 2010 are good

    GCAM_AgLU_SUA_APE_1973_2019_StockAdj1 %>%
      mutate(`Stock Variation` = if_else(OpenStock < 0.001, 0, `Stock Variation`)) %>%
      group_by(GCAM_commodity, region) %>%
      arrange(-year) %>%
      mutate(CumStockVar = cumsum(`Stock Variation`),
             BaseYearClosingStock  = first(`Closing stocks`),
             OpenStock = BaseYearClosingStock - CumStockVar,
             CloseStock = OpenStock +`Stock Variation`) %>%
      ungroup %>%
      # other use is also removed here; it will be re-balanced later in L109
      select(-CumStockVar, -BaseYearClosingStock, -`Closing stocks`, -`Opening stocks`, - `Other uses`) %>%
      rename(`Opening stocks` = OpenStock, `Closing stocks` = CloseStock) ->
      GCAM_AgLU_SUA_APE_1973_2019_StockAdj2



    # 1. Supply-utilization accounting balance ----
    # Change unit and year for later uses
    # data was balanced already and in GCAM regions
    L100.FAO_SUA_APE_balance <-
      GCAM_AgLU_SUA_APE_1973_2019_StockAdj2 %>%
      mutate(Net_Export = Export - Import) %>%
      select(-unit) %>%
      left_join_error_no_match(GCAM_region_names, by = "region") %>%
      select(-region) %>%
      gather(element, value, -GCAM_region_ID, -GCAM_commodity, -year) %>%
      # change unit to Mt
      mutate(value = value / 1000) %>%
      # Adding 5-year moving average here
      dplyr::group_by_at(dplyr::vars(-year, -value)) %>%
      mutate(moving_avg = Moving_average(value, periods = aglu.MODEL_MEAN_PERIOD_LENGTH)) %>%
      ungroup() %>%
      mutate(value = if_else(is.na(moving_avg), value, moving_avg)) %>%
      select(-moving_avg) %>%
      filter(year %in% aglu.AGLU_HISTORICAL_YEARS)


    # 2. Primary crop and meat production and harvested area ----
    ## 2.1. Primary crop production, harvested area, and a combined for downscaling ----

    ##* L100.FAO_ag_Prod_t ----
    # will be used in residual bio
    L100.FAO_ag_Prod_t <-
      FAO_AgProd_Kt_All %>%
      filter(CropMeat %in% c("Crop_Fodder", "Crop_NonFodder")) %>%
      transmute(iso, GCAM_region_ID, item, item_code, year, GCAM_commodity, GCAM_subsector,
                element = "Prod_t", value = value * 1000) %>%
      # Adding 5-year moving average here
      dplyr::group_by_at(dplyr::vars(-year, -value)) %>%
      mutate(moving_avg = Moving_average(value, periods = aglu.MODEL_MEAN_PERIOD_LENGTH)) %>%
      ungroup() %>%
      mutate(value = if_else(is.na(moving_avg), value, moving_avg)) %>%
      select(-moving_avg) %>%
      filter(year %in% aglu.AGLU_HISTORICAL_YEARS)

    ##* L100.FAO_ag_HA_ha ----
    # The file will be used for fertilization related calculation
    L100.FAO_ag_HA_ha <-
      FAO_AgArea_Kha_All %>%
      transmute(iso, GCAM_region_ID, item, item_code, year, GCAM_commodity, GCAM_subsector,
                element = "Area_harvested_ha", value = value * 1000) %>%
      # Adding 5-year moving average here
      dplyr::group_by_at(dplyr::vars(-year, -value)) %>%
      mutate(moving_avg = Moving_average(value, periods = aglu.MODEL_MEAN_PERIOD_LENGTH)) %>%
      ungroup() %>%
      mutate(value = if_else(is.na(moving_avg), value, moving_avg)) %>%
      select(-moving_avg) %>%
      filter(year %in% aglu.AGLU_HISTORICAL_YEARS)

    ##* L100.FAO_PRODSTAT_TO_DOWNSCAL ----
    # Aggregate to GCAM_commodity, GCAM_subsector to downscale to basin later
    L100.FAO_PRODSTAT_TO_DOWNSCAL <-
      L100.FAO_ag_Prod_t %>%
        group_by(iso, GCAM_commodity, GCAM_subsector, year, GCAM_region_ID) %>%
        summarise(Prod_t = sum(value), .groups = "drop") %>%
        ungroup() %>%
        left_join_error_no_match(
          L100.FAO_ag_HA_ha %>%
            group_by(iso, GCAM_commodity, GCAM_subsector, year, GCAM_region_ID) %>%
            summarise(Area_harvested_ha = sum(value), .groups = "drop") %>%
            ungroup(),
          by = c("iso", "GCAM_commodity", "GCAM_subsector", "year", "GCAM_region_ID") )

    ### clean ----
    rm(FAO_AgArea_Kha_All)


    assertthat::assert_that(
      L100.FAO_ag_Prod_t %>%
        filter(!GCAM_commodity %in% c("FodderGrass", "FodderHerb")) %>%
        group_by(GCAM_commodity, year, GCAM_region_ID) %>%
        summarise(value = sum(value)/1000000, .groups = "drop") %>%
        ungroup()  %>%
        left_join_error_no_match(
          L100.FAO_SUA_APE_balance %>% filter(element == "Production") %>%
            filter(GCAM_commodity %in% COMM_CROP) %>%
            select(-element) %>% rename(value1 = value),
          by = c("GCAM_commodity", "year", "GCAM_region_ID")
        ) %>%
        mutate(diff = abs(value1 - value)) %>%
        filter(diff > 0.0001) %>% nrow() == 0,
      msg = "Inconsistency between L100.FAO_SUA_APE_balance and L100.FAO_ag_Prod_t"
    )


    ## 2.2. Livestock Production ----

    ##* L101.an_Prod_Mt_ctry_C_Y ----
    L101.an_Prod_Mt_ctry_C_Y <-
      FAO_AgProd_Kt_All %>%
      filter(CropMeat %in% c("Meat")) %>%
      # complete year and fill zeros
      complete(nesting(area_code, area, iso, GCAM_region_ID),
               nesting(item_code, item, GCAM_commodity, GCAM_subsector, CropMeat), element,
               year, fill = list(value = 0))%>%
      # Adding 5-year moving average here
      dplyr::group_by_at(dplyr::vars(-year, -value)) %>%
      mutate(moving_avg = Moving_average(value, periods = aglu.MODEL_MEAN_PERIOD_LENGTH)) %>%
      ungroup() %>%
      mutate(value = if_else(is.na(moving_avg), value, moving_avg)) %>%
      select(-moving_avg) %>%
      filter(year %in% aglu.AGLU_HISTORICAL_YEARS) %>%
      group_by(iso, GCAM_commodity, year, GCAM_region_ID) %>%
      summarise(value = sum(value), .groups = "drop") %>%
      ungroup() %>%
      # complete year and fill zeros
      #complete(nesting(iso, GCAM_commodity, GCAM_region_ID), year, fill = list(value = 0)) %>%
      # change unit to Mt
      mutate(value = value / 1000)

    ##* L101.an_Prod_Mt_R_C_Y ----
    L101.an_Prod_Mt_R_C_Y <-
      L101.an_Prod_Mt_ctry_C_Y %>%
        group_by(GCAM_region_ID, GCAM_commodity, year) %>%
        summarise(value = sum(value), .groups = "drop") %>%
        ungroup()

    assertthat::assert_that(
      L101.an_Prod_Mt_R_C_Y %>%
        left_join(
          L100.FAO_SUA_APE_balance %>%
            filter(element == "Production") %>%
            filter(GCAM_commodity %in% COMM_MEAT) %>%
            select(-element)%>%
            rename(value1 = value),
          by = c("GCAM_region_ID", "GCAM_commodity", "year")) %>%
        mutate(diff = abs(value1- value)) %>%
        filter(diff > 0.00001) %>% nrow() == 0,
      msg = "Inconsistency between L100.FAO_SUA_APE_balance and L101.an_Prod_Mt_R_C_Y"
    )


    # 3 Food consumption in SUA and Calories----

    FAO_Food_Macronutrient_All_2010_2019 %>%
      filter(year %in% aglu.MODEL_MACRONUTRIENT_YEARS) %>%
      # Aggregate to region and GCAM commodity
      dplyr::group_by_at(vars(GCAM_region_ID, GCAM_commodity, year, macronutrient)) %>%
      summarise(value = sum(value), .groups = "drop") %>%
      # Mean over aglu.MODEL_MACRONUTRIENT_YEARS
      dplyr::group_by_at(vars(GCAM_region_ID, GCAM_commodity, macronutrient)) %>%
      summarise(value = mean(value), .groups = "drop") %>%
      spread(macronutrient, value) ->
      DF_Macronutrient_FoodItem1

    DF_Macronutrient_FoodItem1 %>%
      # NEC is removed by joining
      # though not all food items are consumed in all regions (deal with NA later)
      right_join(
        L100.FAO_SUA_APE_balance %>% # Unit is Mt
          filter(element == "Food",
                 year == dplyr::last(MODEL_BASE_YEARS)),
        by = c("GCAM_region_ID", "GCAM_commodity")
      ) %>%
    # Both data were average already
    transmute(GCAM_region_ID, GCAM_commodity,
              calperg = MKcal / value / 1000,
              fatperc = MtFat / value * 100,
              proteinperc = MtProtein / value * 100) ->
      DF_Macronutrient_FoodItem2


    # We have protein and fat data here but not used in GCAM (dropped here)
    DF_Macronutrient_FoodItem2 %>%
      tidyr::gather(macronutrient, value, calperg:proteinperc) %>%
      # Join max regional conversion for adjustments later
      left_join(
        FAO_Food_MacronutrientRate_2010_2019_MaxValue,
        by = c("GCAM_commodity", "macronutrient")
      ) %>%
      # In rare cases, primary equivalent resulted in lower food mass consumption
      # mainly due to a higher-than-one-extraction rate, e.g., beer of barley
      # or small discrepancies (or possibly representing real processing)
      # thus, the cal per g conversion is larger than the max of the conversion
      # of the corresponding SUA items
      # I.e., a few OtherGrain cases (e.g., Indonesia) and a Mexico soybean case;
      # they all have relatively small consumption/impacts
      # But we use the max of the conversion of the corresponding SUA items to limit the value here
      # mainly for avoiding too different macronutrient rates across regions
      mutate(value = pmin(value, max_macronutrient_value)) %>%
      select(-max_macronutrient_value) %>%
      # There are sill NA values e.g., palm oil is not consumed in Canada
      # And fiber crop is not consumed in few regions
      # Fill in NA with world mean
      dplyr::group_by_at(vars(-GCAM_region_ID, -value)) %>%
      mutate(value = if_else(is.na(value), mean(value, na.rm = T), value)) %>%
      ungroup() %>%
      filter(macronutrient == "calperg") %>%
      spread(macronutrient, value) ->
      DF_Macronutrient_FoodItem3_calperg


    DF_Macronutrient_FoodItem4 <-
      L100.FAO_SUA_APE_balance %>% filter(element == "Food") %>%
      rename(Mt = value) %>%
      left_join_error_no_match(DF_Macronutrient_FoodItem3_calperg,
                               by = c("GCAM_commodity", "GCAM_region_ID")) %>%
      mutate(Kcalperg = calperg / 1000,
             MKcal =  Kcalperg * Mt * 1000) %>%
      select(-calperg)


    ##* L101.ag_Food_Mt_R_C_Y ----
    L101.ag_Food_Mt_R_C_Y <-
      DF_Macronutrient_FoodItem4 %>%
      filter(GCAM_commodity %in% COMM_CROP) %>%
      transmute(GCAM_region_ID, GCAM_commodity, year, value = Mt)

    ##* L101.an_Food_Mt_R_C_Y ----
    L101.an_Food_Mt_R_C_Y <-
      DF_Macronutrient_FoodItem4 %>%
      filter(GCAM_commodity %in% COMM_MEAT) %>%
      transmute(GCAM_region_ID, GCAM_commodity, year, value = Mt)

    ##* L101.ag_Food_Pcal_R_C_Y ----
    L101.CropMeat_Food_Pcal_R_C_Y <-
      DF_Macronutrient_FoodItem4 %>%
      transmute(GCAM_region_ID, GCAM_commodity, year, value = MKcal/1000)

    rm(list = ls(pattern = "DF_Macronutrient_FoodItem*"))


    # 4. Feed and trade ----

    ##* L101.ag_Feed_Mt_R_C_Y ----
    L101.ag_Feed_Mt_R_C_Y <-
      L100.FAO_SUA_APE_balance %>% filter(element == "Feed") %>%
      filter(GCAM_commodity %in% COMM_CROP) %>%
      select(-element)

    ##* L101.GrossTrade_Mt_R_C_Y ----
    # Including both ag and an
    L101.GrossTrade_Mt_R_C_Y <-
      L100.FAO_SUA_APE_balance %>% filter(element %in% c("Export", "Import")) %>%
      spread(element, value) %>%
      rename(GrossExp_Mt = Export, GrossImp_Mt = Import)

    # 5. Ag post-harvest storage loss rate and Ag storage ----

    # For estimating loss rate, it could be complicated due to trade
    # E.g., Japan has large loss-to-production ratio due the loss of imported storage
    # For net importers it is more reasonable to use loss-to-consumption ratio
    # similarly, it is more reasonable to use loss-to-production ratio for net exporters
    # Note that the goal here is to estimate a loss ratio to be applied to ending stock
    # and this loss is only inter-annual stock loss, which is a portion of post-harvest loss.

    L100.FAO_SUA_APE_balance %>%
      filter(element %in% c("Production", "Loss", "Net_Export")) %>%
      spread(element, value) %>%
      mutate(Consumption = Production - Net_Export,
             LossRate_Prod = Loss / Production,
             LossRate_Cons = Loss / Consumption,
             LossRate = if_else(Net_Export >= 0, LossRate_Prod, LossRate_Cons) ) %>%
      select(GCAM_commodity, GCAM_region_ID, year, LossRate, Consumption) ->
      L101.LossRate


    # Another problem is data quality. E.g., Brazil has zero soybean loss;
    # Other regions may have loss values that are unrealistically small

    # Calculate world loss rate using commodity and region with positive loss values
    L100.FAO_SUA_APE_balance %>%
      filter(element %in% c("Production", "Loss")) %>%
      spread(element, value) %>% filter(Loss > 0) %>%
      group_by(GCAM_commodity, year) %>%
      summarise(LossRateWorld = sum(Loss) / sum(Production), .groups = "drop") %>%
      # safeguard complete year and filling in missing
      complete(GCAM_commodity, year, fill = list(LossRateWorld = NA)) %>%
      group_by(GCAM_commodity) %>%
      fill(LossRateWorld, .direction = "downup") %>%
      ungroup() ->
      L101.LossRateWorld

    # Use world value to replace NA or zero
    # Also consumption may have negative values (adjusted later)
    # But set loss to zero for those
    L101.LossRate %>%
      left_join_error_no_match(L101.LossRateWorld,
                               by = c("GCAM_commodity", "year")) %>%
      mutate(LossRate = if_else(is.na(LossRate) | LossRate <= 0, LossRateWorld, LossRate),
             LossRate = if_else(Consumption <= 10e-05, 0, LossRate)) %>%
      select(GCAM_commodity, GCAM_region_ID,  year, value = LossRate) %>%
      mutate(element = "StorageLossRate")->
      L101.StorageLossRate

    # Note that redo the calculation of storage here mainly because of the 5-year average
    # affected the years with missing values
    # but it indeed won't affect results
    L100.FAO_SUA_APE_balance %>%
      filter(element %in% c("Closing stocks", "Opening stocks", "Stock Variation")) %>%
      bind_rows(L101.StorageLossRate) %>%
      # only keep sectors for storage modeling
      # other sectors will have zero storage values filled in later
      filter(GCAM_commodity %in% COMM_STORAGE) %>%
      spread(element, value) %>%
      group_by(GCAM_commodity, GCAM_region_ID) %>%
      # in case COMM_STORAGE is empty
      bind_rows(tibble(`Opening stocks` = numeric(),
                       `Closing stocks` = numeric(),
                       `Stock Variation` = numeric(),
                       `InterAnnualStockLoss` = numeric(),
                       StorageLossRate = numeric() )) %>%
      arrange(-year) %>%
      mutate(CumStockVar = cumsum(`Stock Variation`),
             OpenStock = first(`Closing stocks`) - CumStockVar,
             CloseStock = OpenStock +`Stock Variation`,
             InterAnnualStockLoss = CloseStock * StorageLossRate) %>%
      ungroup() %>%
      select(GCAM_region_ID, GCAM_commodity, year,
             `Opening stocks` = OpenStock,
             `Closing stocks` = CloseStock,
             InterAnnualStockLoss) %>%
      gather(element, value, -GCAM_region_ID, -GCAM_commodity, -year)->
      L101.ag_Storage_Mt_R_C_Y




    # Produce outputs ----
    #********************************* ----
    L100.FAO_SUA_APE_balance %>%
      add_title("Regional agricultural commodity prices for all traded primary GCAM AGLU commodities") %>%
      add_units("1000 tonnes") %>%
      add_comments("Supply utilization balance for GCAM commodities and regions in primary equivalent") %>%
      add_precursors("GCAM_AgLU_SUA_APE_1973_2019",
                     "common/GCAM_region_names") ->
      L100.FAO_SUA_APE_balance

    L100.FAO_ag_HA_ha %>%
      add_title("FAO agricultural harvested area by country, item, year") %>%
      add_comments("Keep detailed FAO area info by item and country for later uses") %>%
      add_units("Ha") %>%
      add_precursors("FAO_AgArea_Kha_All") ->
      L100.FAO_ag_HA_ha

    L100.FAO_ag_Prod_t %>%
      add_title("FAO agricultural production by country, item, year") %>%
      add_comments("Keep detailed FAO production info by item and country for later uses") %>%
      add_units("t") %>%
      add_precursors("FAO_AgProd_Kt_All") ->
      L100.FAO_ag_Prod_t

    L100.FAO_PRODSTAT_TO_DOWNSCAL %>%
      add_title("FAO agricultural production and harvested area by country, GCAM_item, year") %>%
      add_comments("Aggregated to GCAM items for both production and area for downscaling") %>%
      add_units("Ha and t") %>%
      add_precursors("FAO_AgProd_Kt_All",
                     "FAO_AgArea_Kha_All") ->
      L100.FAO_PRODSTAT_TO_DOWNSCAL

    L101.an_Prod_Mt_R_C_Y %>%
      add_title("Animal production by GCAM region / commodity / year") %>%
      add_units("Mt") %>%
      add_comments("Aggregate FAO country and item data by GCAM region commodity, and year") %>%
      add_comments("Convert data from ton to Mt") %>%
      add_legacy_name("L101.an_Prod_Mt_R_C_Y") %>%
      add_precursors("FAO_AgProd_Kt_All") ->
      L101.an_Prod_Mt_R_C_Y

    L101.an_Prod_Mt_ctry_C_Y %>%
      add_title("Animal production by country / commodity / year") %>%
      add_units("Mt") %>%
      add_comments("Aggregate FAO country and item data by GCAM commodity, and year") %>%
      add_comments("Convert data from ton to Mt") %>%
      add_legacy_name("L101.an_Prod_Mt_ctry_C_Y") %>%
      add_precursors("FAO_AgProd_Kt_All") ->
      L101.an_Prod_Mt_ctry_C_Y


    L101.ag_Food_Mt_R_C_Y %>%
      add_title("FAO food consumption by GCAM region, commodity, and year") %>%
      add_units("Mt") %>%
      add_comments("Aggregates FAO data by GCAM region, commodity, and year") %>%
      add_comments("Data is also converted from tons to Mt") %>%
      add_legacy_name("L101.ag_Food_Mt_R_C_Y") %>%
      add_precursors("common/GCAM_region_names",
                     "aglu/FAO/FAO_ag_items_PRODSTAT",
                     "FAO_Food_Macronutrient_All_2010_2019",
                     "FAO_Food_MacronutrientRate_2010_2019_MaxValue") ->
      L101.ag_Food_Mt_R_C_Y

    L101.CropMeat_Food_Pcal_R_C_Y %>%
      add_title("FAO food calories consumption by GCAM region, commodity, and year") %>%
      add_units("Pcal") %>%
      add_comments("Aggregates FAO data by GCAM region, commodity, and year") %>%
      add_comments("Data is also converted from tons to Pcal") %>%
      add_legacy_name("L101.CropMeat_Food_Pcal_R_C_Y") %>%
      same_precursors_as(L101.ag_Food_Mt_R_C_Y) ->
      L101.CropMeat_Food_Pcal_R_C_Y

    L101.an_Food_Mt_R_C_Y %>%
      add_title("Animal consumption by GCAM region / commodity / year") %>%
      add_units("Mt") %>%
      add_comments("Aggregate FAO country and item data by GCAM region, commodity, and year") %>%
      add_comments("Convert data from ton to Mt") %>%
      add_legacy_name("L101.an_Food_Mt_R_C_Y") %>%
      add_precursors("common/GCAM_region_names",
                     "GCAM_AgLU_SUA_APE_1973_2019",
                     "aglu/FAO/FAO_an_items_PRODSTAT",
                     "FAO_Food_Macronutrient_All_2010_2019",
                     "FAO_Food_MacronutrientRate_2010_2019_MaxValue") ->
      L101.an_Food_Mt_R_C_Y

    L101.ag_Feed_Mt_R_C_Y %>%
      add_title("Feed use by GCAM region, commodity, and year aggregated from FAO") %>%
      add_comments("Feed consumption of GCAM Ag commodities; they will be adjusted in L108") %>%
      add_units("Mt") %>%
      add_legacy_name("L101.ag_Feed_Mt_R_C_Y") %>%
      add_precursors("GCAM_AgLU_SUA_APE_1973_2019",
                     "aglu/FAO/FAO_ag_items_PRODSTAT") ->
      L101.ag_Feed_Mt_R_C_Y

    L101.GrossTrade_Mt_R_C_Y %>%
      add_title("Gross trade by GCAM region, commodity, and year aggregated from FAO") %>%
      add_comments("Balanced gross trade of GCAM Ag commodities") %>%
      add_units("Mt") %>%
      add_legacy_name("L101.GrossTrade_Mt_R_C_Y") %>%
      add_precursors("GCAM_AgLU_SUA_APE_1973_2019") ->
      L101.GrossTrade_Mt_R_C_Y

    L101.ag_Storage_Mt_R_C_Y %>%
      add_title("Ag storage and loss by GCAM region, commodity, and year aggregated from FAO") %>%
      add_comments("Balanced element in SUA for GCAM Ag commodities") %>%
      add_units("Mt") %>%
      add_legacy_name("L101.ag_Storage_Mt_R_C_Y") %>%
      add_precursors("GCAM_AgLU_SUA_APE_1973_2019",
                     "aglu/A_agStorageSector") ->
      L101.ag_Storage_Mt_R_C_Y


    # Done & return data----
    return_data(MODULE_OUTPUTS)

  } else {
    stop("Unknown command")
  }
}
