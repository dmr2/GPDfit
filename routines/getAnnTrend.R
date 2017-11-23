getAnnTrend <- function(root,gauge,basin,mainDir){
  
  ann_fil <- Sys.glob(paste(root,basin,"/annual/annual_sl_",basin,"_",gauge,"_*.tsv",sep=""))
  
  print(paste("Opening: ",ann_fil))
  annual = read.csv(ann_fil,sep=";",header=FALSE,quote="\"",comment.char = "")
  
  all_vals = annual$V2
  all_vals[all_vals == -99999] <- NA
  
  all_years = annual$V1
  yr_last <- all_years[length(all_years)]
  
  # get annual trend for the last 30-years in record
  trend_vals <- all_vals[all_years >= (yr_last-29) & all_years <= yr_last]

  trend_yrs <- seq((yr_last-29),yr_last)
  fit30 <- lm(trend_vals ~ trend_yrs, na.action=na.omit)
  
  # Print annual trend
  annual_trend30 <- format(as.numeric(fit30$coef[2]),digits=4)
  
  fit <- lm(all_vals ~ all_years, na.action=na.omit)
  annual_trend_all <- as.numeric(fit$coef[2])
  
  i <- which(gauge_dat$Gauge==gauge)
  print(paste(paste("[",gauge_dat$Long_Name[i],", ",gauge_dat$Region[i],"]",sep=""),paste(yr_last-29,"-",yr_last)," Annual trend: ",annual_trend30," mm/yr"))
  
  #Plot and save time series of annual averages
  fil <- paste("slr_trend_",basin,"_",gauge,".png",sep="")
  dir.create(file.path(mainDir,"annualSL_trends"),showWarnings = FALSE)
  dir.create(paste(file.path(mainDir,"annualSL_trends"),basin,sep="/"),showWarnings = FALSE)

  trend_path <- file.path(mainDir,"annualSL_trends",basin,fil)
  png(trend_path,width=800,height=500,res=120)
  subtitle = paste(yr_last-29,"-",yr_last,"trend:",annual_trend30,"mm/yr",sep=" ")
  plot(all_years,all_vals,xlab="Year",ylab="MSL Height (mm)")
  time = paste("(",all_years[1],"-",yr_last,")",sep="")
  title(paste(gauge,gauge_dat$Long_Name[i],gauge_dat$Region[i],time,sep=" "),sub=subtitle)
  
  # plot trend
  Y <- predict(fit30, newdata=data.frame(x=trend_yrs))
  lines(x=trend_yrs, y=Y,col="red",lty=2,lwd=2)
  dev.off()  
  
  return(annual_trend_all)
  
}