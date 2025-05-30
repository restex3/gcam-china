% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/zchunk_LA100.FAO_preprocessing_OtherData.R
\name{module_aglu_LA100.FAO_preprocessing_OtherData}
\alias{module_aglu_LA100.FAO_preprocessing_OtherData}
\title{module_aglu_LA100.FAO_preprocessing_OtherData}
\usage{
module_aglu_LA100.FAO_preprocessing_OtherData(command, ...)
}
\arguments{
\item{command}{API command to execute}

\item{...}{other optional parameters, depending on command}
}
\value{
Depends on \code{command}: either a vector of required inputs,
a vector of output names, or (if \code{command} is "MAKE") all
the generated outputs: \code{L100.FAO_CL_kha}, \code{L100.FAO_fallowland_kha}, \code{L100.FAO_harv_CL_kha},
\code{L100.FAO_Fert_Cons_tN}, \code{L100.FAO_Fert_Prod_tN}, \code{L100.FAO_For_Exp_m3}, \code{L100.FAO_For_Imp_m3}, \code{L100.FAO_For_Prod_m3}.
}
\description{
Get FAO data ready for forestry, fertilizer, animal stock, and land cover
}
\details{
Get FAO data ready for forestry, fertilizer, animal stock, and land cover.
Calculate rolling five-year averages.
}
\author{
BBL XZ 2022
}
