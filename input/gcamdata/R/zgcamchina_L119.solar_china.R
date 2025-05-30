# Copyright 2019 Battelle Memorial Institute; see the LICENSE file.

#' module_gcamchina_L119.Solar
#'
#' Compute capacity factors for solar capacity factors by province.
#'
#' @param command API command to execute
#' @param ... other optional parameters, depending on command
#' @return Depends on \code{command}: either a vector of required inputs,
#' a vector of output names, or (if \code{command} is "MAKE") all
#' the generated outputs: \code{L119.CapFacScaler_PV_province}, \code{L119.CapFacScaler_CSP_province}. The corresponding file in the
#' original data system was \code{LA114.Solar.R} (gcam-china level1).
#' @details Computes solar capacity factor scalars for PV and CSP technologies by province, divided by the national average.
#' @importFrom assertthat assert_that
#' @importFrom dplyr filter mutate select
#' @importFrom tidyr gather spread
#' @author Liu July 2018 / Ou Dec 2023
module_gcamchina_L119.Solar <- function(command, ...) {
  if(command == driver.DECLARE_INPUTS) {
    return(c(FILE = "gcam-china/solar_csp_pv_capacityfactor",
             FILE = "gcam-china/province_names_mappings"))
  } else if(command == driver.DECLARE_OUTPUTS) {
    return(c("L119.CapFacScaler_PV_province",
             "L119.CapFacScaler_CSP_province"))
  } else if(command == driver.MAKE) {

    fuel  <- CSP  <- sector <- scaler <-
      province.name <- province <- Centralized.PV <- NULL     # silence package check.

    all_data <- list(...)[[1]]
    # -----------------------------------------------------------------------------
    # 1.Load required inputs
    province_names_mappings     <- get_data(all_data, "gcam-china/province_names_mappings")
    solar_csp_pv_capacityfactor <- get_data(all_data, "gcam-china/solar_csp_pv_capacityfactor", strip_attributes = T)

    # -----------------------------------------------------------------------------
    # 2.perform computations
    # Create scalers to scale capacity factors read in the assumptions file.
    # These scalers will then be used to create capacity factors by province.
    # The idea is to vary capacity factors for solar technologies by province depending on the varying solar irradiance by province.
    # Create scalers by province by dividing capacity factor by the average.
    solar_csp_pv_capacityfactor %>%
      mutate(sector = "electricity generation",
             fuel = "solar PV",
             scaler = Centralized.PV / Centralized.PV[province.name == "Average"]) %>%
      filter(province.name != "Average") %>%
      map_province_name(province_names_mappings, "province", TRUE) %>%
      select(province, sector, fuel, scaler) ->
      L119.CapFacScaler_PV_province

    solar_csp_pv_capacityfactor %>%
      mutate(sector = "electricity generation",
             fuel = "solar CSP",
             scaler = CSP / CSP[province.name == "Average"]) %>%
      filter(province.name != "Average") %>%
      map_province_name(province_names_mappings, "province", TRUE) %>%
      select(province, sector, fuel, scaler) ->
      L119.CapFacScaler_CSP_province


    # ===================================================
    L119.CapFacScaler_PV_province %>%
      add_title("Solar PV capacity factor adjustment by province") %>%
      add_units("Unitless") %>%
      add_comments("The scalars are generated by dividing data on capacity factors by province by national average capacity factor") %>%
      add_legacy_name("L119.CapFacScaler_PV_province") %>%
      add_precursors("gcam-china/province_names_mappings", "gcam-china/solar_csp_pv_capacityfactor") ->
      L119.CapFacScaler_PV_province

    L119.CapFacScaler_CSP_province %>%
      add_title("Solar CSP capacity factor adjustment by province") %>%
      add_units("Unitless") %>%
      add_comments("The scalars are generated by dividing data on capacity factors by province by national average capacity factor") %>%
      add_legacy_name("L119.CapFacScaler_CSP_province") %>%
      add_precursors("gcam-china/province_names_mappings", "gcam-china/solar_csp_pv_capacityfactor") ->
      L119.CapFacScaler_CSP_province

    return_data(L119.CapFacScaler_PV_province, L119.CapFacScaler_CSP_province)
  } else {
    stop("Unknown command")
  }
}
