## Run analysis, write model results

## Before:
## After:

library(icesTAF)
taf.library(stockassessment)

mkdir("model")
load(file="data/data.RData")


#- Fit the model
fit.new <-sam.fit(dat,conf,par,  map=list(logitRecapturePhi=factor(c(1,1))))


#- Run retrospectives
ret<-stockassessment::retro(fit.new, year=7)     
ret5peels<-stockassessment::retro(fit.new, year=5)

# leave one out ----------------------------------------------------------------
fit.new.wo<-runwithout(fit.new, year=2013:2023, fleet=rep(5,10), map=list(logitRecapturePhi=factor(c(1))))
fit.new.wo3<-runwithout(fit.new,  fleet=c(3), map=list( logSdLogFsta=factor(c(1,2,2))))
lo<-leaveout(fit.new, fleet=c(2,3,4))
lo$"w.o. RFID"<-fit.new.wo
lo$"w.o. R-idx"<-fit.new.wo3

ret_noRFID <- stockassessment::retro(lo$"w.o. RFID",year=5) 
ret_noIESSNS <- stockassessment::retro(lo$"w.o. Swept-idx",year=5) 

# residuals --------------------------------------------------------------------
options(mc.cores=3)

dat<-fit.new$data
dis<-dat$fleetTypes[dat$aux[,"fleet"]]==5
res<-TMB::oneStepPredict(fit.new$obj, observation.name="logobs", data.term.indicator="keep", discrete=FALSE, subset=which(!dis), parallel=TRUE)
res2<-TMB::oneStepPredict(fit.new$obj, observation.name="logobs", data.term.indicator="keep", discrete=TRUE, conditional=which(!dis),
                          subset=which(dis), method ="oneStepGeneric", range=c(0,Inf), parallel=TRUE)

totalres<-rep(NA,nrow(dat$aux))
totalres[!dis]<-res$residual
totalres[dis]<-res2$residual
myres<-data.frame(dat$aux, residual=totalres)

TAGRES<-myres[myres$fleet==5,]
myres$residual[myres$fleet==5]<-NA
class(myres)<-"samres"
attr(myres, "fleetNames")<-attr(fit.new$data, "fleetNames")
RES<-myres
RESP<-procres(fit.new)


#- Save all relevant objects
save(fit.new, fit.new.wo,fit.new.wo3,ret,ret5peels,ret_noRFID,ret_noIESSNS,dat,par,conf,res,res2,myres,RES,TAGRES,RESP,RES,TAGRES,file="model/model.RData")
