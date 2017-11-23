source("GPDsample.R")
source("GPDNExceed.R")

getCurveData <- function(type,site,threshold,lambda,scale,shape,shapeV,scaleV,shapescaleV){

# Account for GPD parameter uncertainty by making draws from a
# bivariate normal distribution using Latin hypercube sampling
GPD <- GPDsample(1000, scale, shape, shapeV, scaleV, shapescaleV)

z <- seq(0,10,.01) # some flood heights (meters above tide gauge MHHW)

# Flood curves that include GPD parameter uncertainty
qqq <- matrix(NaN, nrow=length(GPD[,2]), ncol=length(z))
for(iii in 1:length(GPD[,2]) ){
  qqq[iii,] <- GPDNExceed(z-threshold,lambda,-threshold,GPD[iii,2],GPD[iii,1])
}

confint <- apply(qqq,2,quantile,probs=c(0.167,0.5,0.833),na.rm=T) # 50th & 17/83 confidence intervals

# Expected historical flood height curve (No SLR)
Ne_hist <- apply(qqq,2,mean,na.rm=T) # return period for historical storms

freq <- as.numeric(Ne_hist)
name <- rep(type,length(z))

#histcurve <- data.frame(height=z,N=Ne_hist,loc=site,name)

df <- data.frame(height=z,Ne=freq,q17=confint[1,],q50=confint[2,],q83=confint[3,],loc=site,name)

return ( df )

}