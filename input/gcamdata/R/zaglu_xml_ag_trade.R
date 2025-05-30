# Copyright 2019 Battelle Memorial Institute; see the LICENSE file.

#' module_aglu_ag_trade_xml
#'
#' Construct XML data structure for \code{ag_trade.xml}.
#'
#' @param command API command to execute
#' @param ... other optional parameters, depending on command
#' @return Depends on \code{command}: either a vector of required inputs,
#' a vector of output names, or (if \code{command} is "MAKE") all
#' the generated outputs: \code{ag_trade.xml}.
module_aglu_ag_trade_xml <- function(command, ...) {

  MODULE_INPUTS <-
    c("L240.Supplysector_tra",
      "L240.SectorUseTrialMarket_tra",
      "L240.SubsectorAll_tra",
      "L240.TechShrwt_tra",
      "L240.TechCost_tra",
      "L240.TechCoef_tra",
      "L240.Production_tra",
      "L240.Supplysector_reg",
      "L240.SubsectorAll_reg",
      "L240.TechShrwt_reg",
      "L240.TechCoef_reg",
      "L240.Production_reg_imp",
      "L240.Production_reg_dom")

  MODULE_OUTPUTS <-
    c(XML = "ag_trade.xml")

  if(command == driver.DECLARE_INPUTS) {
    return(MODULE_INPUTS)
  } else if(command == driver.DECLARE_OUTPUTS) {
    return(MODULE_OUTPUTS)
  } else if(command == driver.MAKE) {

    all_data <- list(...)[[1]]

    # Load required inputs ----
    get_data_list(all_data, MODULE_INPUTS, strip_attributes = TRUE)

    # ===================================================



    # Produce outputs
    create_xml("ag_trade.xml") %>%
      add_logit_tables_xml(L240.Supplysector_tra, "Supplysector") %>%
      add_xml_data(L240.SectorUseTrialMarket_tra, "SectorUseTrialMarket") %>%
      add_logit_tables_xml(L240.SubsectorAll_tra, "SubsectorAll", base_logit_header = "SubsectorLogit") %>%
      add_xml_data(L240.TechShrwt_tra, "TechShrwt") %>%
      add_xml_data(L240.TechCost_tra, "TechCost") %>%
      add_xml_data(L240.TechCoef_tra, "TechCoef") %>%
      add_xml_data(L240.Production_tra, "Production") %>%
      add_logit_tables_xml(L240.Supplysector_reg, "Supplysector") %>%
      add_logit_tables_xml(L240.SubsectorAll_reg, "SubsectorAll", base_logit_header = "SubsectorLogit") %>%
      add_xml_data(L240.TechShrwt_reg, "TechShrwt") %>%
      add_xml_data(L240.TechCoef_reg, "TechCoef") %>%
      add_xml_data(L240.Production_reg_imp, "Production") %>%
      add_xml_data(L240.Production_reg_dom, "Production") %>%
      add_precursors("L240.Supplysector_tra",
                     "L240.SectorUseTrialMarket_tra",
                     "L240.SubsectorAll_tra",
                     "L240.TechShrwt_tra",
                     "L240.TechCost_tra",
                     "L240.TechCoef_tra",
                     "L240.Production_tra",
                     "L240.Supplysector_reg",
                     "L240.SubsectorAll_reg",
                     "L240.TechShrwt_reg",
                     "L240.TechCoef_reg",
                     "L240.Production_reg_imp",
                     "L240.Production_reg_dom") ->
      ag_trade.xml

    return_data(MODULE_OUTPUTS)
  } else {
    stop("Unknown command")
  }
}
