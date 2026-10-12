## Preprocess data, write TAF data tables

## Before:
## After:

library(icesTAF)
taf.library(stockassessment)

mkdir("data")

cat("!! please check : some values are hardcoded and need to be updated each year \n")

read.ices.taf <- function(...) {
  read.ices(taf.data.path(...))
}


cn<-read.ices.taf("cn.dat")
cw<-read.ices.taf("cw.dat")
dw<-read.ices.taf("dw.dat")
lf<-read.ices.taf("lf.dat")
lw<-read.ices.taf("lw.dat")
mo<-read.ices.taf("mo.dat")
nm<-read.ices.taf("nm.dat")
pf<-read.ices.taf("pf.dat")
pm<-read.ices.taf("pm.dat")
sw<-read.ices.taf("sw.dat")
surveys<-read.ices.taf("survey.dat")

recap<-read.table(taf.data.path("tag_steel.dat"), header=TRUE)
recap<-recap[recap$Type==1 & recap$RecaptureY<=2006,]
recap<-recap[recap[,1]>=min(as.numeric(rownames(sw))), ]

recap2<-read.table(taf.data.path("tag_RFID.dat"), header=TRUE)
recap2$r<-round(recap2$r)
recap2<-recap2[recap2$Nscan>0,]
age <- recap2$ReleaseY - recap2$Yearclass
# subset of the data according to changes made in IBP 2019
recap2 <- recap2[age>4,]
recap2 <- recap2[(recap2$RecaptureY-recap2$ReleaseY) %in% c(1,2), ]
recap2 <- recap2[recap2$ReleaseY>=2013, ]

recap<-rbind(recap,recap2)

age<- recap$ReleaseY - recap$Yearclass
recap  <- recap[age>1 & age<12,]     # possibly test id <13 ok???

#### Remove the tags recapture in the release year
recap <- recap[recap$ReleaseY!=recap$RecaptureY,]

# remove scans of catch in the current Y
recap <- recap[recap$RecaptureY!=2024,]     
recap$R <- as.numeric(recap$R)

#- Se weights
W<-matrix(NA,nrow=nrow(cn), ncol=ncol(cn))
W[as.numeric(rownames(cn))<2000]<-10
attr(cn,"weight")<-W


#recap$splitPhi=rep(1,nrow(recap))    # that is actually part of model configuration, but not included in the conf file

dat<-setup.sam.data(surveys=surveys,
                    residual.fleet=cn, 
                    prop.mature=mo, 
                    stock.mean.weight=sw, 
                    catch.mean.weight=cw, 
                    dis.mean.weight=dw, 
                    land.mean.weight=lw,
                    prop.f=pf, 
                    prop.m=pm, 
                    natural.mortality=nm, 
                    land.frac=lf,
                    recapture=recap)


#- Read configuration

conf<-defcon(dat)
conf$keyLogFsta[1,] <- c(0,1,2,3,4,5,6,7,7,7,7,7,7)
conf$keyVarObs[4,]      <- c(-1,-1,-1, 3,4,4,4,4,4,4,4,4,-1)
conf$fbarRange <- c(4,8)
conf$corFlag <- 0
conf$fixVarToWeight<-1
conf$obsCorStruct[] <- c("ID", "ID", "ID", "AR", "ID")
#conf$keyCorObs[4,7:11]<-0
conf$keyCorObs[4,]<-c(-1 ,-1, -1 , 0  ,0 , 0,  0,  0,  0,   0 ,  0 , -1)

conf$keyVarF[1,]    <- c(0,1,rep(2,6),rep(-1,5))

conf$keyVarObs[1,]   <- c( 0,1,rep(2,11) )
conf$keyVarObs[2,1]  <- 3
conf$keyVarObs[3,1]  <- 4
conf$keyVarObs[4,]   <- c(-1, -1, -1,  5, 6,  6,  6,  6, 6,  6,  6,   6,  -1 )

#- Set default starting parameters
par<-defpar(dat,conf)

#save data and config
save(dat,conf,par,file="data/data.RData")