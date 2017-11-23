#!/opt/local/bin/R

# Calculate GDP parameters from tide gauge data

# Inputs:
#   - Daily maximum tide gauge data (e.g., from U Hawaii SL Center data)
#   - Annual average SL data

# Outputs:
#   - Text files with flood heights above MHHW over 99th percentile
#   - Plots with information about GPD parameter fits
#   - Plots with annual SL data over time and latest 30-yr trend
#   - GPD parameters for each tide gauge


rm(list=ls(all=TRUE))
mainDir <- "/Users/dmr/Dropbox/IPCC\ Sea\ Level/GPD_fit"
setwd(mainDir)

library("extRemes")

source("routines/getTG.R")
source("routines/getAnnTrend.R")
source("routines/getMonTrend.R")
source("routines/OpenDailyMaxTide.R")
source("routines/DeclusterTide.R")
source("routines/getGPDparams.R")


root = "/Users/dmr/hawaiiSL\ 2017/data/global/"

basin = "pacific" # indian | atlantic | pacific

# Determine what tidge gauges we will process based   
# on dailies that meet data completion requirements
metafil <- paste(root,basin,"/daily_max/",basin,"_meta.tsv",sep="")
gauge_dat <- getTG2(metafil)
gauge_list <- gauge_dat$Gauge

df <- data.frame(UHAWAII_ID=character(),PSMSL_ID=character(),
                 Site=character(),Basin=character(),Lat=double(),Lon=double(),
                 Region=character(),Record_Start=integer(),Record_End=integer(),
                 Annual_Trend=double(),Trend_Start=integer(),Trend_End=integer(),
                 Lambda=double(),Q99=double(),Shape50=double(),Shape5=double(),
                 Shape95=double(),Scale50=double(),Scale5=double(),Scale95=double(),
                 Vshape=double(),Vscale=double(),Vscaleshape=double(),stringsAsFactors=FALSE)

# Loop over each tide gauge
for(i in 1:length(gauge_list)){
  
  dir1 <- paste(root,basin,"/daily_max",sep="")
  daily <- OpenDailyMaxTide(dir1,basin,gauge_list[i],gauge_dat)
  
  # Before doing anything, de-trend observations using annual
  annual_trend <- getAnnTrend(root,gauge_list[i],basin,mainDir)
  
  # only use dailies in the part of the complete tide gauge 
  # record that meets the data completion requirements
  y1d <- gauge_dat$QA_Record_Start_Day[i]
  y2d <- gauge_dat$QA_Record_End_Day[i]
  raw_vals <- daily$Max_Tide[daily$Year >= y1d & daily$Year <= y2d]
  mask <- (raw_vals == -999)
  
  v <- 1:length(raw_vals)
  detrend_vals <- raw_vals - (annual_trend/365.25)*v
  detrend_vals[mask] = -999 
  
  # Use latest 19-year period in the record as the tidal epoch
  time <- daily$Year[daily$Year >= y1d & daily$Year <= y2d]
  mhhw_period <- detrend_vals[time >= (y2d-18) & time <= y2d]
  
  # Calculate MMHW for the epoch from above
  mhhw <- mean(mhhw_period[mhhw_period!=-999])
  
  # calculate tides relative to MHHW
  tide_rel_to_mhhw <- ((detrend_vals - mhhw)/1000)
  tide_rel_to_mhhw[mask] = -999
  
  # Use 99th percentile as GPD threshold
  q99 <- quantile(tide_rel_to_mhhw,.99)
  
  # Decluster exceedances above the GPD threshold
  dc_tide_rel_to_mhhw <- DeclusterTide(tide_rel_to_mhhw,q99)
  
  # write historical exceedances to disk
  subDir <- paste("obs_q99exceed_",basin,sep="")
  dir.create(file.path(mainDir, subDir), showWarnings = FALSE)

  outf <- paste(subDir,"/obs_q99exceed_",basin,"_gauge_",gauge_list[i],".csv",sep="")
  write.table(dc_tide_rel_to_mhhw,file=outf,col.names = FALSE,row.names = FALSE)
  
  # Calculate Poission and GPD parameters
  data_exceed <- dc_tide_rel_to_mhhw[dc_tide_rel_to_mhhw > q99]
  lambda <- length(data_exceed)/(length(dc_tide_rel_to_mhhw)/365.25)
  
  fit <- gpdFit(data_exceed,q99,basin,gauge_list[i])
  fit_ci <- ci.fevd(fit,alpha=0.05,type="parameter")
  
  vscale <- parcov.fevd(fit)[1]
  vshape <- parcov.fevd(fit)[4]
  cov <- parcov.fevd(fit)[2]
  
  scale5 <- fit_ci[1]
  scale50 <- fit_ci[3]
  scale95 <- fit_ci[5]
  
  shape5 <- fit_ci[2]
  shape50 <- fit_ci[4]
  shape95 <- fit_ci[6]
 
   df <- rbind(df, data.frame(UHAWAII_ID=gauge_dat$Gauge[i],
                              PSMSL_ID=gsub("[^0-9\\.]", "00000",gauge_dat$Gauge[i]),
                              Site=gauge_dat$Long_Name[i],
                              Basin=basin,
                              Lat=gauge_dat$Lat[i],Lon=gauge_dat$Lon[i],
                              Region=gauge_dat$Region[i],
                              GPD_Record_Start=gauge_dat$QA_Record_Start_Day[i],
                              GPD_Record_End=gauge_dat$QA_Record_End_Day[i],
                              Annual_Trend=annual_trend,Trend_Start=gauge_dat$QA_Record_Start_Day[i],
                              Trend_End=gauge_dat$QA_Record_End_Day[i],
                              Lambda=lambda,Q99=q99,
                              Shape50=shape50,Shape5=shape5,Shape95=shape95,
                              Scale50=scale50,Scale5=scale5,Scale95=scale95,
                              Vshape=vshape,Vscale=vscale,Vscaleshape=cov))
        
} # each tide gauge

# write file with GPD parameters for this basin only
outfil <- paste("gpd_parameters_",basin,".tsv",sep="")
write.table(df,file=outfil,quote = TRUE, sep = "\t", eol = "\n", na = "NA",
            dec = ".", row.names = FALSE, col.names = TRUE)
