## Extract results of interest, write TAF output tables

## Before:
## After:

library(icesTAF)

mkdir("output")

pdf("output/diagnostics.pdf", 6, 6)
ssbplot(fit.new)
fbarplot(fit.new)
recplot(fit.new)
catchplot(fit.new)
fitplot(fit.new, fleet=1)
fitplot(fit.new, fleet=2, ylim=c(14.5, 16))
fitplot(fit.new, fleet=3)
fitplot(fit.new, fleet=4)
source("fitplot.tags.r")
fitplot.tags(fit.new)
plot(RESP)
plotby(TAGRES$year, TAGRES$RecaptureY-TAGRES$year, TAGRES$residual, by=TAGRES$age, xlab="Year", ylab="No years out"); title(paste(round(range(TAGRES$residual),1), collapse=" - "))
plot(RES)

ssbplot(ret,main="retro SSB")
fbarplot(ret,partial=F,main="retro Fbar")
recplot(ret,main = "retro Recruitment" , las=0, drop=1)
catchplot( ret, main = "retro Catch")


ssbplot(ret_noRFID,main="retro SSB, leave out RFID")



## compare the stock trajectories
par(mfrow=c(1,2),mar=c(4,5,1,1))
ssbplot(fit.new,         col="black",  cicol=rgb(0,0,0,0.1),main="leave one out SSB")
ssbplot(lo[[1]],  add=T, col="red",   ci=F)
ssbplot(lo[[2]],  add=T, col="chartreuse4",  ci=F)
ssbplot(lo[[3]],  add=T, col="blue",   ci=F)
ssbplot(lo[[4]],  add=T, col="darkorchid2", ci=F)
ssbplot(fit.new, add=T,  col="black",  ci=F)

legend(legend =c("all in", names(lo)), col = c("black","red","chartreuse4","blue","darkorchid2") ,lwd=3 , lty=c(1),x="top" ,bg="white")

fbarplot(fit.new, partial = F ,        col="black",  cicol=rgb(0,0,0,0.1),main="leave one out Fbar")
fbarplot(lo[[1]], partial = F , add=T, col="red",   ci=F)
fbarplot(lo[[2]], partial = F , add=T, col="chartreuse4",  ci=F)
fbarplot(lo[[3]], partial = F , add=T, col="blue",   ci=F)
fbarplot(lo[[4]], partial = F , add=T, col="darkorchid2", ci=F)
fbarplot(fit.new, partial = F , add=T, col="black",  ci=F)

recplot(fit.new,         col="black",  cicol=rgb(0,0,0,0.1),main="leave one out Recruitment")
recplot(lo[[1]],  add=T, col="red",   ci=F)
recplot(lo[[2]],  add=T, col="chartreuse4",  ci=F)
recplot(lo[[3]],  add=T, col="blue",   ci=F)
recplot(lo[[4]],  add=T, col="darkorchid2", ci=F)
recplot(fit.new, add=T,  col="black",  ci=F)
 
dev.off()
