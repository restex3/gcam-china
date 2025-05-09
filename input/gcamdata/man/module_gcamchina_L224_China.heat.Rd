% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/zchunk_L224.heat_CHINA.R
\name{module_gcamchina_L224_China.heat}
\alias{module_gcamchina_L224_China.heat}
\title{module_gcamchina_L224_China.heat}
\usage{
module_gcamchina_L224_China.heat(command, ...)
}
\arguments{
\item{command}{API command to execute}

\item{...}{other optional parameters, depending on command}
}
\value{
Depends on \code{command}: either a vector of required inputs,
a vector of output names, or (if \code{command} is "MAKE") all
the generated outputs: \code{L224.SectorLogitTables[[ curr_table ]]$data}, \code{L224.Supplysector_heat_china}, \code{L224.SubsectorLogitTables[[ curr_table ]]$data}, \code{L224.SubsectorLogit_heat_china}, \code{L224.SubsectorShrwt_heat_china}, \code{L224.SubsectorShrwtFllt_heat_china}, \code{L224.SubsectorInterp_heat_china}, \code{L224.SubsectorInterpTo_heat_china}, \code{L224.StubTech_heat_china},  \code{L224.StubTechCalInput_heat_china}, \code{L224.StubTechSecOut_elec_china}, \code{L224.StubTechCost_elec_china}, \code{L224.StubTechMarket_heat_CHINA} . The corresponding file in the
original data system was \code{L224.heat.R} (energy level2).
}
\description{
Write Chinese district heat sector outputs.
}
\details{
This chunk creates level 2 output files for district heat sector. It creates supply sector information,
subsector logit exponents, subsector shareweight and interpolation, and stubtech info by writing assumption file
information to all model periods and regions that have district heat. It creates global tech coef, costs, and shareweights
by interpolating assumptions. From the level 1 heat data, this chunk computes stub tech calibrated inputs, secondary
outputs from elec and modified costs.
}
\author{
Yangliu Sep 2020 / YangOu Aug-Dec 2023
}
