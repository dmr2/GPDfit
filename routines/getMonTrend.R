getMonTrend <- function(gauge,basin,gauge_dat){
  
  y1m <- gauge_dat$QA_Record_Start_Mon[i]
  y2m <- gauge_dat$QA_Record_End_Mon[i]
  
  fn <- paste("monthly_sl_",basin,"_",gauge_list[i],"_",gauge_dat$Record_Start_Mon[i],"-",gauge_dat$Record_End_Mon[i],".tsv",sep="")
  mon_fil <- paste(root,"monthly",basin,fn,sep="/")
  
  print(paste("Opening: ",mon_fil))
  monthly = read.csv(mon_fil,sep="\t",header=TRUE,quote="\"",comment.char = "")
  
  vals <- monthly$Height[monthly$Year >= y1m & monthly$Year <= y2m]
  
  vals[vals == -999] <- NA
  
  x <- 1:length(vals)
  fit <- lm(vals ~ x, na.action=na.omit)
  
  # trend per day (mm/day)
  trend <- as.numeric(fit$coef[2])/(365.25/12)
  
  return(trend)
  
}