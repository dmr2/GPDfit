plotGPDNExceed2Curves <- function( df, df2, obs, obs2, site ){

  library(ggplot2)
  library(scales)
  
  print(obs$name)
  p <- ggplot(df)  + 
    # plot GPD uncertainty 
    geom_line(data=df, aes(x=height,y=Ne,colour=name),lwd=1.5,alpha=.6) +
    geom_line(data=df, aes(x=height,y=q17,colour=name),lty=2,lwd=.5,alpha=.6) +
    geom_line(data=df, aes(x=height,y=q50,colour=name),lty=1,lwd=.5,alpha=.6) +
    geom_line(data=df, aes(x=height,y=q83,colour=name),lty=2,lwd=.5,alpha=.6) +
    geom_point(data=obs, aes(x=z,y=freq,color=type),size=5,
               stroke=1.5,alpha=0.5) +
    geom_line(data=df2, aes(x=height,y=Ne,colour=name),lwd=1.5,alpha=.6) +
    geom_line(data=df2, aes(x=height,y=q17,colour=name),lty=2,lwd=.5,alpha=.6) +
    geom_line(data=df2, aes(x=height,y=q50,colour=name),lty=1,lwd=.5,alpha=.6) +
    geom_line(data=df2, aes(x=height,y=q83,colour=name),lty=2,lwd=.5,alpha=.6) +
    geom_point(data=obs2, aes(x=z,y=freq,color=type),size=5,
                stroke=1.5,alpha=0.5) +
   # scale_shape_manual(values=c(1,1),breaks=obs$type) +
   # scale_color_manual(values=c("#e41a1c","#377eb8"),breaks = c(df$name,df2$name)) +
    theme_bw(base_size = 27) + annotation_logticks(sides = "lr", size=1,
    short = unit(0.3, "cm"), mid = unit(0.3, "cm"), long = unit(0.5, "cm")) + 
    scale_x_continuous(breaks=seq(0,5,1),limits=c(0,5),expand = c(0,0)) + 
    scale_y_log10(limits=c(.0001,10),breaks=c(10,1,0.1,0.01,0.001,0.0001),
                  labels=trans_format("log10", scales::math_format(10^.x)),expand = c(0,0)) +
    theme(legend.justification = c(1, 1), legend.position = c(1, 1), 
          legend.title = element_blank(),legend.key = element_blank(),
          panel.grid.minor = element_blank(), aspect.ratio=.5,
          panel.border = element_rect(linetype = "solid", colour = "black", size=2),
          axis.line = element_line(colour = 'black', size = 5),
          axis.ticks = element_line(colour = "black", size = 1),
          legend.key.size = unit(2, 'lines')) +
    labs(title=df$loc, x="Flood Height (m)",y="Expected Events per Year") 
  
   fil = paste(site,"_test.pdf",sep="")
   ggsave(fil,p,width=11, height=8.5)
  # Plot in Feet
}

plotGPDNExceed <- function( df, obs, site ){
  
  library(ggplot2)
  library(scales)
  
  print(obs$name)
  p <- ggplot(df)  + 
    # plot GPD uncertainty 
    geom_line(data=df, aes(x=height,y=Ne,colour="N_e"),lwd=1.5,alpha=.9) +
    geom_line(data=df, aes(x=height,y=q17,colour="N_e"),lty=2,lwd=.5,alpha=.9) +
    geom_line(data=df, aes(x=height,y=q50,colour="N_e"),lty=1,lwd=.5,alpha=.9) +
    geom_line(data=df, aes(x=height,y=q83,colour="N_e"),lty=2,lwd=.5,alpha=.9) +
    geom_point(data=obs, aes(x=z,y=freq,shape=group),size=5,
               stroke=1.5,alpha=0.5,color="black") +
     scale_shape_manual(values=1,breaks=obs$group) +
     scale_color_manual(values=c("#e41a1c","#377eb8"),breaks = df$name) +
    theme_bw(base_size = 27) + annotation_logticks(sides = "lr", size=1,
                                                   short = unit(0.3, "cm"), mid = unit(0.3, "cm"), long = unit(0.5, "cm")) + 
    scale_x_continuous(breaks=seq(0,5,1),limits=c(0,5),expand = c(0,0)) + 
    scale_y_log10(limits=c(.0001,10),breaks=c(10,1,0.1,0.01,0.001,0.0001),
                  labels=trans_format("log10", scales::math_format(10^.x)),expand = c(0,0)) +
    theme(legend.justification = c(1, 1), legend.position = c(1, 1), 
          legend.title = element_blank(),legend.key = element_blank(),
          panel.grid.minor = element_blank(), aspect.ratio=.5,
          panel.border = element_rect(linetype = "solid", colour = "black", size=2),
          axis.line = element_line(colour = 'black', size = 5),
          axis.ticks = element_line(colour = "black", size = 1),
          legend.key.size = unit(2, 'lines')) +
    labs(title=df$loc, x="Flood Height (m)",y="Expected Events per Year") 
  
  fil = paste("histflood_",df$name[1],"_",site,".pdf",sep="")
  ggsave(fil,p,width=11, height=8.5)
  
}