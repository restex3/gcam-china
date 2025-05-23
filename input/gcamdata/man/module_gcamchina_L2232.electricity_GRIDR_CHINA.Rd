% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/zchunk_L2232.electricity_GRIDR_CHINA.R
\name{module_gcamchina_L2232.electricity_GRIDR_CHINA}
\alias{module_gcamchina_L2232.electricity_GRIDR_CHINA}
\title{module_gcamchina_L2232.electricity_GRIDR_CHINA}
\usage{
module_gcamchina_L2232.electricity_GRIDR_CHINA(command, ...)
}
\arguments{
\item{command}{API command to execute}

\item{...}{other optional parameters, depending on command}
}
\value{
Depends on \code{command}: either a vector of required inputs,
a vector of output names, or (if \code{command} is "MAKE") all
the generated outputs: \code{L2232.DeleteSupplysector_CHINAelec}, \code{L2232.Supplysector_CHINAelec},
\code{L2232.SubsectorShrwtFllt_CHINAelec}, \code{L2232.SubsectorInterp_CHINAelec}, \code{L2232.SubsectorLogit_CHINAelec},
\code{L2232.TechShrwt_CHINAelec}, \code{L2232.TechCoef_CHINAelec}, \code{L2232.Production_exports_CHINAelec},
\code{L2232.Supplysector_elec_GRIDR}, \code{L2232.ElecReserve_GRIDR}, \code{L2232.SubsectorShrwtFllt_elec_GRIDR},
\code{L2232.SubsectorInterp_elec_GRIDR}, \code{L2232.SubsectorLogit_elec_GRIDR}, \code{L2232.TechShrwt_elec_GRIDR},
\code{L2232.TechCoef_elec_GRIDR}, \code{L2232.TechCoef_elecownuse_GRIDR}, \code{L2232.Production_imports_GRIDR},
\code{L2232.Production_elec_gen_GRIDR}, \code{L2232.StubTechElecMarket_backup_CHINA}. The corresponding file in the
original data system was \code{L2232.electricity_GRIDR_CHINA.R} (gcam-china level2).
}
\description{
Generate GCAM-CHINA model inputs for electrcity trade sectors at the level of grid regions.
}
\details{
This code file only builds the electric sector model input if the demand is being resolved at the level of the grid regions.
}
\author{
YangLiu Jan 2020
}
