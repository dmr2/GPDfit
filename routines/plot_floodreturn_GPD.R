# Plot GPD curves using Rasmussen parameters

rm(list=ls(all=TRUE))
setwd("/Users/dmr/Dropbox/IPCC Sea Level/GPDfit")

library("reshape")
source("getCurveData.R")
source("histStorms.R")
source("plotGPDNExceed.R")

basin = "pacific"

path <- "/Users/dmr/Dropbox/IPCC Sea Level/GPDfit/"
fil <- paste(path,"gpd_parameters_",basin,".tsv",sep="")

dmr_param <- read.csv(fil,sep="\t",header=TRUE,quote="\"",comment.char = "")

for( i in 1:length(dmr_param$UHAWAII_ID)){
  
  # DMR -- GPD 
  threshold <- dmr_param$Q99[i]
  lambda <- dmr_param$Lambda[i]
  scale <- dmr_param$Scale50[i]
  shape <- dmr_param$Shape50[i]
  shapeV <- dmr_param$Vshape[i]
  scaleV <- dmr_param$Vscale[i]
  shapescaleV <- dmr_param$Vscaleshape[i]
  
  site <- paste(dmr_param$Site[i]," ",dmr_param$Region[i]," (",dmr_param$GPD_Record_Start[i],"-",dmr_param$GPD_Record_End[i],")",sep="")
  
  dmr_curve <- getCurveData(basin,site,threshold,lambda,scale,shape,shapeV,scaleV,shapescaleV)
  
  # get historical observations
  fil <- paste("/Users/dmr/Dropbox/IPCC Sea Level/GPDfit/obs_q99exceed_",basin,"_gauge_",dmr_param$UHAWAII_ID[i],".csv",sep="")
  obs_dmr <- histStorms(fil,threshold,"dmr")
  
  # Plot the curve
  plotGPDNExceed(dmr_curve,obs_dmr,dmr_param$UHAWAII_ID[i])
  
}