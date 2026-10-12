# ============================================================================
# UPload Assessment Data into SAG
#
# 17/08/2021 Updated for HAWG 2021
# 30/04/2022 Updated for HAWG 2022
# ============================================================================

rm(list=ls())

library(icesTAF)

taf.library(FLCore)
taf.library(stockassessment)
taf.library(FLSAM)

library(tidyverse)
library(icesSAG)  # install.packages("icesSAG")

# Warning in install.packages :
#   package ‘icesSAG’ is not available for this version of R
# 
# A version of this package for your version of R might be available elsewhere,
# see the ideas at
# https://cran.r-project.org/doc/manuals/r-patched/R-admin.html#Installing-packages

runName <- 'model'

model.save      <- file.path(".",'model')
load(file.path(model.save,paste0(runName,'.RData')))

# use token
options(icesSAG.use_token = TRUE)


# Set years and ranges
FiY   <- dims(ARG)$minyear
DtY   <- dims(ARG)$maxyear
LaY   <- dims(ARG)$maxyear+1 #lag-years
nyrs  <- ((DtY)-(FiY))+1
nyrs2 <- ((LaY)-(FiY))+1

# Meta information
stockkeylabel  <- "aru.27.5b6a"
assessmentyear <- 2024
contactperson  <- "Hannipo@hav.fo"

# SSB in intermediate year 
SSBint <- 84488   # to be updated after the forecast

# Create the input data for uploading  
info     <- icesSAG::stockInfo(
  StockCode      = stockkeylabel, 
  AssessmentYear = assessmentyear, 
  ContactPerson  = contactperson)

info$StockCategory             <- "1"
info$MSYBtrigger               <- 82999
info$Blim                      <- 59730
info$Bpa                       <- 82999
info$Flim                      <- NA
info$Fpa                       <- 0.33
info$FMSY                      <- 0.24
info$Fage                      <- "6-14" 
info$RecruitmentAge            <- 5
info$CatchesLandingsUnits      <- "t"
info$RecruitmentDescription    <- "age"
info$RecruitmentUnits          <- "thousand" 
info$FishingPressureDescription<- "F"
info$FishingPressureUnits      <- NA 
info$StockSizeDescription      <- "SSB"
info$StockSizeUnits            <- "t"
info$Purpose                   <- "Advice"
info$CustomSeriesName1         <- "model catch"
info$CustomSeriesName2         <- "model catch low"
info$CustomSeriesName3         <- "model catch high"
info$ModelName                 <- "SAM"
info$ModelType                 <- "A"
info$ConfidenceIntervalDefinition <- "tst"

# Create the fish data
fishdata                          <- stockFishdata(FiY:LaY)

fishdata$Catches[1:nyrs]          <- an(ARG@landings)[1:nyrs]

fishdata$Low_Recruitment[1:nyrs]        <- rec(ARG.sam)$lbnd
fishdata$Recruitment[1:nyrs]            <- rec(ARG.sam)$value
fishdata$High_Recruitment[1:nyrs]       <- rec(ARG.sam)$ubnd 

fishdata$Low_StockSize[1:nyrs]          <- ssb(ARG.sam)$lbnd[1:nyrs]
fishdata$StockSize                      <- c(ssb(ARG.sam)$value[1:nyrs], SSBint)
fishdata$High_StockSize[1:nyrs]         <- ssb(ARG.sam)$ubnd[1:nyrs]

fishdata$Low_TBiomass[1:nyrs]           <- tsb(ARG.sam)$lbnd[1:nyrs]
fishdata$TBiomass[1:nyrs]               <- tsb(ARG.sam)$value[1:nyrs]
fishdata$High_TBiomass[1:nyrs]          <- tsb(ARG.sam)$ubnd[1:nyrs]

fishdata$Low_FishingPressure[1:nyrs]    <- fbar(ARG.sam)$lbnd[1:nyrs]
fishdata$FishingPressure[1:nyrs]        <- fbar(ARG.sam)$value[1:nyrs]
fishdata$High_FishingPressure[1:nyrs]   <- fbar(ARG.sam)$ubnd[1:nyrs]

fishdata$CustomSeries1[1:nyrs]        <- catch(ARG.sam)$value[1:nyrs]
fishdata$CustomSeries2[1:nyrs]        <- catch(ARG.sam)$lbnd[1:nyrs]
fishdata$CustomSeries3[1:nyrs]        <- catch(ARG.sam)$ubnd[1:nyrs]

# View(fishdata)

# upload to SAG
key <- icesSAG::uploadStock(info, fishdata)

# Get SAG settings
# getSAGSettingsForAStock(assessmentKey=key) %>% View()
# getSAGSettingsForAStock(assessmentKey=14095) %>% View()

# Add comment to SAG settings
# setSAGSettingForAStock(assessmentKey=key, 
#                        chartKey=0,
#                        settingKey=21,
#                        settingValue="My text for the comment field",
#                        copyNextYear=FALSE) 

