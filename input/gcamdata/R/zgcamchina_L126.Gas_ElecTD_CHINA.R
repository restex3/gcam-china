# Copyright 2019 Battelle Memorial Institute; see the LICENSE file.

#' module_gcamchina_L126.Gas_ElecTD
#'
#' Calculates inputs and outputs of transmission and distribution of electricity by province.
#'
#' @param command API command to execute
#' @param ... other optional parameters, depending on command
#' @return Depends on \code{command}: either a vector of required inputs,
#' a vector of output names, or (if \code{command} is "MAKE") all
#' the generated outputs: \code{L126.in_EJ_province_td_elec}. The corresponding file in the
#' original data system was \code{LB126.Gas_ElecTD.R} (gcam-china level1).
#' @details Calculates inputs and outputs of transmission and distribution of electricity by province.
#' @importFrom assertthat assert_that
#' @importFrom dplyr bind_rows filter group_by left_join mutate select summarise transmute
#' @author RLH September 2017 / YangOu 2023
module_gcamchina_L126.Gas_ElecTD <- function(command, ...) {
  if(command == driver.DECLARE_INPUTS) {
    return(c("L122.in_EJ_province_refining_F",
             "L123.out_EJ_province_elec_F",
             "L132.in_EJ_province_indchp_F",
             "L132.in_EJ_province_indfeed_F",
             "L132.in_EJ_province_indnochp_F",
             "L1321.in_EJ_province_cement_F_Y",
             "L1322.in_EJ_province_Fert_Yh",
             "L144.in_EJ_province_bld_F_U",
             "L154.in_EJ_province_trn_F",
             "L126.IO_R_electd_F_Yh"))
  } else if(command == driver.DECLARE_OUTPUTS) {
    return(c("L126.in_EJ_province_td_elec"))
  } else if(command == driver.MAKE) {

    # Silence package checks
    GCAM_region_ID <- year <- value <- value.x <- value.y <- sector <- fuel <- province <- EIA_sector <-
      EIA_fuel <- sector.x <- NULL

    all_data <- list(...)[[1]]

    # Load required inputs
    L126.IO_R_electd_F_Yh <- get_data(all_data, "L126.IO_R_electd_F_Yh") %>%
      filter(GCAM_region_ID == gcamchina.REGION_ID) %>%
      select(-GCAM_region_ID)
    L122.in_EJ_province_refining_F <- get_data(all_data, "L122.in_EJ_province_refining_F")
    L123.out_EJ_province_elec_F <- get_data(all_data, "L123.out_EJ_province_elec_F")
    L132.in_EJ_province_indchp_F <- get_data(all_data, "L132.in_EJ_province_indchp_F")
    L132.in_EJ_province_indfeed_F <- get_data(all_data, "L132.in_EJ_province_indfeed_F")
    L132.in_EJ_province_indnochp_F <- get_data(all_data, "L132.in_EJ_province_indnochp_F")
    L1321.in_EJ_province_cement_F_Y <- get_data(all_data, "L1321.in_EJ_province_cement_F_Y")
    L1322.in_EJ_province_Fert_Yh <- get_data(all_data, "L1322.in_EJ_province_Fert_Yh")
    L144.in_EJ_province_bld_F_U <- get_data(all_data, "L144.in_EJ_province_bld_F_U")
    L154.in_EJ_province_trn_F <- get_data(all_data, "L154.in_EJ_province_trn_F")

    # ===================================================

    # ELECTRICITY TRANSMISSION AND DISTRIBUTION

    L126.in_EJ_province_S_F <- bind_rows(L122.in_EJ_province_refining_F, L123.out_EJ_province_elec_F,
                                         L132.in_EJ_province_indchp_F, L132.in_EJ_province_indfeed_F,
                                         L132.in_EJ_province_indnochp_F %>% select(-GCAM_region_ID, -multiplier),
                                         L1321.in_EJ_province_cement_F_Y,
                                         L1322.in_EJ_province_Fert_Yh, L144.in_EJ_province_bld_F_U %>% select(-service),
                                         L154.in_EJ_province_trn_F)

    # Final energy by fuel
    L126.in_EJ_province_F <- L126.in_EJ_province_S_F %>%
      filter(year %in% HISTORICAL_YEARS) %>%
      group_by(province, fuel, year) %>%
      summarise(value = sum(value)) %>%
      ungroup()

    # Compile each province's total elec consumption: refining, bld, ind, trn.
    L126.in_EJ_province_elec <- L126.in_EJ_province_F %>%
      filter(fuel == "electricity")

    # Deriving electricity T&D output as the sum of all tracked demands of electricity
    L126.out_EJ_province_td_elec <- L126.in_EJ_province_elec %>%
      mutate(sector = "elect_td") %>%
      select(province, sector, fuel, year, value)

    # Assigning all provinces the national average T&D coefficients from L126.IO_R_electd_F_Yh
    L126.in_EJ_province_td_elec <- L126.out_EJ_province_td_elec %>%
      left_join_error_no_match(L126.IO_R_electd_F_Yh, by = c("fuel", "year")) %>%
      # Province input elec = Province output elec * coefficient
      mutate(value = value.x * value.y) %>%
      select(province, sector = sector.x, fuel, year, value)

    # ===================================================

    # Produce outputs

    L126.in_EJ_province_td_elec %>%
      add_title("Input to electricity T&D sector by province") %>%
      add_units("EJ") %>%
      add_comments("Output electricity multiplied by T&D coefficient") %>%
      add_comments("can be multiple lines") %>%
      add_legacy_name("L126.in_EJ_state_td_elec") %>%
      add_precursors("L122.in_EJ_province_refining_F",
                     "L123.out_EJ_province_elec_F",
                     "L132.in_EJ_province_indchp_F",
                     "L132.in_EJ_province_indfeed_F",
                     "L132.in_EJ_province_indnochp_F",
                     "L1321.in_EJ_province_cement_F_Y",
                     "L1322.in_EJ_province_Fert_Yh",
                     "L144.in_EJ_province_bld_F_U",
                     "L154.in_EJ_province_trn_F",
                     "L126.IO_R_electd_F_Yh") ->
      L126.in_EJ_province_td_elec

    return_data(L126.in_EJ_province_td_elec)

  } else {
    stop("Unknown command")
  }
}
