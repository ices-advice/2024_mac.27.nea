fitplot.tags <- function(fit, log=TRUE,fleets=5, ...){
  idx<-fit$data$aux[,"fleet"]%in%fleets
  trans <- function(x)if(log){x}else{exp(x)}
  p <- trans(fit$obj$report(c(fit$sdrep$par.fixed,fit$sdrep$par.random))$predObs[idx])
  o <- trans(fit$data$logobs[idx])
  aa <- fit$data$aux[idx,"age"]
  neg.age <- (aa < -1.0e-6)
  aa[neg.age] <- NA
  a <- paste0("a=",aa," ")
  f <- paste0(" f=",strtrim(attr(fit$data,"fleetNames")[fit$data$aux[idx,"fleet"]],50))
  dt <- as.data.frame(fit$data$aux[idx,])
  dt$obs <- o
  dt$pred <- p
  dt$YO <- as.factor(dt$RecaptureY - dt$year)
  levels(dt$YO) <-  levels(dt$YO)
 # etiquette <- factor(paste("Release Age" ,age))
#  levels(etiquette)

f <- ggplot(subset(dt, Type==2) ) +
          geom_line (aes(x=year , y = pred ,colour = YO ) ) +
          geom_point(aes(x=year , y = obs ,colour = YO ) ) +
          facet_wrap(~paste("Release Age" ,age))         +
          scale_colour_discrete("Years at Liberty") +
          xlab("Release Year")  + ylab("predicted (-) vs. observed (o) recaptures")
          print(f)
}