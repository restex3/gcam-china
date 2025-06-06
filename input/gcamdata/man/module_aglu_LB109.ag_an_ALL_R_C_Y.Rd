% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/zchunk_LB109.ag_an_ALL_R_C_Y.R
\name{module_aglu_LB109.ag_an_ALL_R_C_Y}
\alias{module_aglu_LB109.ag_an_ALL_R_C_Y}
\title{module_aglu_LB109.ag_an_ALL_R_C_Y}
\usage{
module_aglu_LB109.ag_an_ALL_R_C_Y(command, ...)
}
\arguments{
\item{command}{API command to execute}

\item{...}{other optional parameters, depending on command}
}
\value{
Depends on \code{command}: either a vector of required inputs,
a vector of output names, or (if \code{command} is "MAKE") all
the generated outputs: \code{L109.ag_ALL_Mt_R_C_Y}, \code{L109.an_ALL_Mt_R_C_Y}. The corresponding file in the
original data system was \code{LB109.ag_an_ALL_R_C_Y.R} (aglu level1).
}
\description{
Calculate primary agricultural good and animal product mass balances, by region / commodity / year.
}
\details{
This chunk combines all flow tables of GCAM agricultural commodities, calculates mass balances by
GCAM region, commodity and year, and adjusts global and regional net exports to remove negative other uses.
}
\author{
RC April 2017 XZ 2022
}
