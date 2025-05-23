% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/zchunk_L2234.elec_segments_CHINA.R
\name{module_gcamchina_L2234.elec_segments_CHINA}
\alias{module_gcamchina_L2234.elec_segments_CHINA}
\title{module_gcamchina_L2234.elec_segments_CHINA}
\usage{
module_gcamchina_L2234.elec_segments_CHINA(command, ...)
}
\arguments{
\item{command}{API command to execute}

\item{...}{other optional parameters, depending on command}
}
\value{
Depends on \code{command}: either a vector of required inputs,
a vector of output names, or (if \code{command} is "MAKE") all
the generated outputs: \code{L2234.Supplysector_elecS_CHINA}, \code{L2234.ElecReserve_elecS_CHINA}, \code{L2234.SubsectorLogit_elecS_CHINA},
\code{L2234.SubsectorShrwtInterp_elecS_CHINA}, \code{L2234.SubsectorShrwtInterpTo_elecS_CHINA}, \code{L2234.SubsectorShrwt_elecS_CHINA},
\code{L2234.StubTechEff_elecS_CHINA}, \code{L2234.StubTechCapFactor_elecS_solar_CHINA}, \code{L2234.StubTechCapFactor_elecS_wind_CHINA},
\code{L2234.SubsectorShrwtFllt_elecS_grid_CHINA}, \code{L2234.SubsectorShrwtInterp_elecS_grid_CHINA}, \code{L2234.PassThroughSector_elecS_CHINA},
\code{L2234.PassThroughTech_elecS_grid_CHINA}, \code{L2234.GlobalTechShrwt_elecS_CHINA}, \code{L2234.GlobalIntTechShrwt_elecS_CHINA},
\code{L2234.PrimaryRenewKeyword_elecS_CHINA},\code{L2234.PrimaryRenewKeywordInt_elecS_CHINA}, \code{L2234.AvgFossilEffKeyword_elecS_CHINA},
\code{L2234.GlobalTechCapital_elecS_CHINA}, \code{L2234.GlobalIntTechCapital_elecS_CHINA}, \code{L2234.GlobalTechOMfixed_elecS_CHINA},
\code{L2234.GlobalIntTechOMfixed_elecS_CHINA}, \code{L2234.GlobalTechOMvar_elecS_CHINA}, \code{L2234.GlobalIntTechOMvar_elecS_CHINA},
\code{L2234.GlobalTechCapFac_elecS_CHINA}, \code{L2234.GlobalTechEff_elecS_CHINA}, \code{L2234.GlobalIntTechEff_elecS_CHINA},
\code{L2234.GlobalTechLifetime_elecS_CHINA}, \code{L2234.GlobalIntTechLifetime_elecS_CHINA}, \code{L2234.GlobalTechProfitShutdown_elecS_CHINA},
\code{L2234.GlobalTechSCurve_elecS_CHINA}, \code{L2234.GlobalTechCapture_elecS_CHINA}, \code{L2234.GlobalIntTechBackup_elecS_CHINA},
\code{L2234.StubTechMarket_elecS_CHINA}, \code{L2234.StubTechMarket_backup_elecS_CHINA}, \code{L2234.StubTechElecMarket_backup_elecS_CHINA},
\code{L2234.StubTechProd_elecS_CHINA}, \code{L2234.StubTechFixOut_elecS_CHINA}, \code{L2234.StubTechFixOut_hydro_elecS_CHINA},
\code{L2234.TechShrwt_elecS_grid_CHINA}, \code{L2234.TechCoef_elecS_grid_CHINA}, \code{L2234.TechProd_elecS_grid_CHINA}.
The corresponding file in the original data system was \code{L2234.elec_segments_CHINA.R} (gcam-china level2).
}
\description{
Generates gcam-china model inputs for multiple load segments electricity sector by province.
}
\details{
This chunk generates input files to create an electricity generation sector with multiple load segments
for each province and creates the demand for the province-level electricity sectors in the grid regions.
}
\author{
MTB Aug 2018 / YangOu Jul 2023
}
