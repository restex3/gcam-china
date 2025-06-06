# Copyright 2019 Battelle Memorial Institute; see the LICENSE file.

#' module_gcamusa_industry_xml
#'
#' Construct XML data structure for \code{industry_USA.xml}.
#'
#' @param command API command to execute
#' @param ... other optional parameters, depending on command
#' @return Depends on \code{command}: either a vector of required inputs,
#' a vector of output names, or (if \code{command} is "MAKE") all
#' the generated outputs: \code{industry_USA.xml}. The corresponding file in the
#' original data system was \code{batch_industry_USA_xml.R} (gcamusa XML).
module_gcamusa_industry_xml <- function(command, ...) {
  if(command == driver.DECLARE_INPUTS) {
    return(c("L232.DeleteSupplysector_USAind",
             "L232.DeleteFinalDemand_USAind",
             "L232.DeleteStubCalorieContent_USAind",
             "L232.DeleteDomSubsector_USAind",
             "L232.DeleteTraSubsector_USAind",
             "L232.Supplysector_ind_USA",
             "L232.FinalEnergyKeyword_ind_USA",
             "L232.SubsectorLogit_ind_USA",
             "L232.SubsectorShrwtFllt_ind_USA",
             "L232.SubsectorInterp_ind_USA",
             "L232.StubTech_ind_USA",
             "L232.StubTechInterp_ind_USA",
             "L232.PerCapitaBased_ind_USA",
             "L232.PriceElasticity_ind_USA",
             "L232.IncomeElasticity_ind_gcam3_USA",
             "L232.StubTechCalInput_indenergy_USA",
             "L232.StubTechCalInput_indfeed_USA",
             "L232.StubTechProd_industry_USA",
             "L232.StubTechCoef_industry_USA",
             "L232.StubTechMarket_ind_USA",
             "L232.BaseService_ind_USA",
             "L232.StubTechSecMarket_ind_USA",
             "L232.Production_reg_imp",
             "L232.BaseService_iron_steel"))
  } else if(command == driver.DECLARE_OUTPUTS) {
    return(c(XML = "industry_USA.xml"))
  } else if(command == driver.MAKE) {

    all_data <- list(...)[[1]]

    # Load required inputs
    L232.DeleteSupplysector_USAind <- get_data(all_data, "L232.DeleteSupplysector_USAind")
    L232.DeleteFinalDemand_USAind <- get_data(all_data, "L232.DeleteFinalDemand_USAind")
    L232.DeleteStubCalorieContent_USAind <- get_data(all_data, "L232.DeleteStubCalorieContent_USAind")
    L232.DeleteDomSubsector_USAind <- get_data(all_data, "L232.DeleteDomSubsector_USAind")
    L232.DeleteTraSubsector_USAind <- get_data(all_data, "L232.DeleteTraSubsector_USAind")
    L232.Production_reg_imp <- get_data(all_data, "L232.Production_reg_imp")
    L232.BaseService_iron_steel <- get_data(all_data, "L232.BaseService_iron_steel")
    L232.Supplysector_ind_USA <- get_data(all_data, "L232.Supplysector_ind_USA")
    L232.FinalEnergyKeyword_ind_USA <- get_data(all_data, "L232.FinalEnergyKeyword_ind_USA")
    L232.SubsectorLogit_ind_USA <- get_data(all_data, "L232.SubsectorLogit_ind_USA")
    L232.SubsectorShrwtFllt_ind_USA <- get_data(all_data, "L232.SubsectorShrwtFllt_ind_USA")
    L232.SubsectorInterp_ind_USA <- get_data(all_data, "L232.SubsectorInterp_ind_USA")
    L232.StubTech_ind_USA <- get_data(all_data, "L232.StubTech_ind_USA")
    L232.StubTechInterp_ind_USA <- get_data(all_data, "L232.StubTechInterp_ind_USA")
    L232.PerCapitaBased_ind_USA <- get_data(all_data, "L232.PerCapitaBased_ind_USA")
    L232.PriceElasticity_ind_USA <- get_data(all_data, "L232.PriceElasticity_ind_USA")
    L232.IncomeElasticity_ind_gcam3_USA <- get_data(all_data, "L232.IncomeElasticity_ind_gcam3_USA")
    L232.StubTechCalInput_indenergy_USA <- get_data(all_data, "L232.StubTechCalInput_indenergy_USA")
    L232.StubTechCalInput_indfeed_USA <- get_data(all_data, "L232.StubTechCalInput_indfeed_USA")
    L232.StubTechProd_industry_USA <- get_data(all_data, "L232.StubTechProd_industry_USA")
    L232.StubTechCoef_industry_USA <- get_data(all_data, "L232.StubTechCoef_industry_USA")
    L232.StubTechMarket_ind_USA <- get_data(all_data, "L232.StubTechMarket_ind_USA")
    L232.StubTechSecMarket_ind_USA <- get_data(all_data, "L232.StubTechSecMarket_ind_USA")
    L232.BaseService_ind_USA <- get_data(all_data, "L232.BaseService_ind_USA")

    # ===================================================

    # Produce outputs
    create_xml("industry_USA.xml") %>%
      add_xml_data(L232.DeleteSupplysector_USAind, "DeleteSupplysector") %>%
      add_xml_data(L232.DeleteFinalDemand_USAind, "DeleteFinalDemand") %>%
      add_xml_data_generate_levels(L232.DeleteStubCalorieContent_USAind, "DeleteStubTechMinicamEnergyInput","subsector","nesting-subsector",1,FALSE) %>%
      add_xml_data(L232.DeleteDomSubsector_USAind, "DeleteSubsector") %>%
      add_xml_data(L232.DeleteTraSubsector_USAind, "DeleteSubsector") %>%
      add_xml_data(L232.Production_reg_imp, "Production") %>%
      add_xml_data(L232.BaseService_iron_steel, "BaseService") %>%
      add_logit_tables_xml(L232.Supplysector_ind_USA, "Supplysector") %>%
      add_xml_data(L232.FinalEnergyKeyword_ind_USA, "FinalEnergyKeyword") %>%
      add_logit_tables_xml(L232.SubsectorLogit_ind_USA, "SubsectorLogit") %>%
      add_xml_data(L232.SubsectorShrwtFllt_ind_USA, "SubsectorShrwtFllt") %>%
      add_xml_data(L232.SubsectorInterp_ind_USA, "SubsectorInterp") %>%
      add_xml_data(L232.StubTech_ind_USA, "StubTech") %>%
      add_xml_data(L232.StubTechInterp_ind_USA, "StubTechInterp") %>%
      add_xml_data(L232.PerCapitaBased_ind_USA, "PerCapitaBased") %>%
      add_xml_data(L232.PriceElasticity_ind_USA, "PriceElasticity") %>%
      add_xml_data(L232.IncomeElasticity_ind_gcam3_USA, "IncomeElasticity") %>%
      add_xml_data(L232.StubTechCalInput_indenergy_USA, "StubTechCalInput") %>%
      add_xml_data(L232.StubTechCalInput_indfeed_USA, "StubTechCalInput") %>%
      add_xml_data(L232.StubTechProd_industry_USA, "StubTechProd") %>%
      add_xml_data(L232.StubTechCoef_industry_USA, "StubTechCoef") %>%
      add_xml_data(L232.StubTechMarket_ind_USA, "StubTechMarket") %>%
      add_xml_data(L232.StubTechSecMarket_ind_USA, "StubTechSecMarket") %>%
      add_xml_data(L232.BaseService_ind_USA, "BaseService") %>%
      add_precursors("L232.DeleteSupplysector_USAind",
                     "L232.DeleteFinalDemand_USAind",
                     "L232.DeleteStubCalorieContent_USAind",
                     "L232.DeleteTraSubsector_USAind",
                     "L232.DeleteDomSubsector_USAind",
                     "L232.Supplysector_ind_USA",
                     "L232.FinalEnergyKeyword_ind_USA",
                     "L232.SubsectorLogit_ind_USA",
                     "L232.SubsectorShrwtFllt_ind_USA",
                     "L232.SubsectorInterp_ind_USA",
                     "L232.StubTech_ind_USA",
                     "L232.StubTechInterp_ind_USA",
                     "L232.PerCapitaBased_ind_USA",
                     "L232.PriceElasticity_ind_USA",
                     "L232.IncomeElasticity_ind_gcam3_USA",
                     "L232.StubTechCalInput_indenergy_USA",
                     "L232.StubTechCalInput_indfeed_USA",
                     "L232.StubTechProd_industry_USA",
                     "L232.StubTechCoef_industry_USA",
                     "L232.StubTechMarket_ind_USA",
                     "L232.BaseService_ind_USA",
                     "L232.StubTechSecMarket_ind_USA",
                     "L232.Production_reg_imp",
                     "L232.BaseService_iron_steel") ->
      industry_USA.xml

    return_data(industry_USA.xml)
  } else {
    stop("Unknown command")
  }
}
