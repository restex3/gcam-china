# Copyright 2019 Battelle Memorial Institute; see the LICENSE file.

#' module_emissions_ssp2_emissions_factors_xml
#'
#' Construct XML data structure for \code{ssp2_emissions_factors.xml}.
#'
#' @param command API command to execute
#' @param ... other optional parameters, depending on command
#' @return Depends on \code{command}: either a vector of required inputs,
#' a vector of output names, or (if \code{command} is "MAKE") all
#' the generated outputs: \code{ssp2_emissions_factors.xml}. The corresponding file in the
#' original data system was \code{batch_ssp2_emissions_factors_xml.R} (emissions XML).
module_emissions_ssp2_emissions_factors_xml <- function(command, ...) {
  if(command == driver.DECLARE_INPUTS) {
    return(c("L251.ssp2_ef",
             "L251.ssp2_ef_elec",
              "L251.ssp2_ef_vin",
             "L251.ssp2_ef_residTradBio"))
  } else if(command == driver.DECLARE_OUTPUTS) {
    return(c(XML = "ssp2_emissions_factors.xml",
             XML = "ssp2_emissions_factors_tradBio.xml"))
  } else if(command == driver.MAKE) {

    all_data <- list(...)[[1]]

    # Load required inputs
    L251.ssp2_ef <- get_data(all_data, "L251.ssp2_ef")
    L251.ssp2_ef_residTradBio <- get_data(all_data, "L251.ssp2_ef_residTradBio")
    L251.ssp2_ef_elec <- get_data(all_data, "L251.ssp2_ef_elec")
    L251.ssp2_ef_vin <- get_data(all_data, "L251.ssp2_ef_vin")

    # Silence package checks
    emiss.coeff <- NULL

    # ===================================================

    # Rename L251.ssp2_ef column to match the expected column
    # names in the add_xml_data header.
    L251.ssp2_ef <- rename(L251.ssp2_ef, `emiss.coef` = `emiss.coeff`)
    L251.ssp2_ef_residTradBio <- rename(L251.ssp2_ef_residTradBio, `emiss.coef` = `emiss.coeff`)

    # Produce outputs
    create_xml("ssp2_emissions_factors.xml") %>%
      add_xml_data(L251.ssp2_ef, "InputEmissCoeff") %>%
      add_xml_data(L251.ssp2_ef_elec, "OutputEmissCoeff") %>%
      add_xml_data(L251.ssp2_ef_vin, "ReadInControl") %>%
      add_precursors("L251.ssp2_ef", "L251.ssp2_ef_elec", "L251.ssp2_ef_vin") ->
      ssp2_emissions_factors.xml

    create_xml("ssp2_emissions_factors_tradBio.xml") %>%
      add_xml_data(L251.ssp2_ef_residTradBio, "InputEmissCoeff") %>%
      add_precursors("L251.ssp2_ef_residTradBio") ->
      ssp2_emissions_factors_tradBio.xml

    return_data(ssp2_emissions_factors.xml, ssp2_emissions_factors_tradBio.xml)
  } else {
    stop("Unknown command")
  }
}
