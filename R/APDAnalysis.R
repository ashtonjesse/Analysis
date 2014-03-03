#Load the s20x library
library("s20x")

#load the data
APDdata <- read.table("G:/PhD/Experiments/Bordeaux/Data/20131129/Baro005/APD50/APDData.txt", sep = ",", header = TRUE)

#Produce a boxplot of the CVdata by beat
APDdataByBeat <- t(APDdata[,1:ncol(APDdata)])
dev.new(width=8.27,height=5.845)
par(mar = c(0,0,0,0))
par(mai = c(0.4,0.2,0.4,0))
par(pin = c(5,4))
boxplot(APDdataByBeat , main=paste("APD distributions for each beat"), pars=list(ylab="APD (ms)",xlab="Beat number"))
dev.copy(png,"G:/PhD/Experiments/Bordeaux/Data/20131129/Baro005/APD50/APDDistByBeat.png",width=2480,height=1753,pointsize=12,res=300)
dev.off()
dev.new(width=8.27,height=5.845)
par(mar = c(0,0,0,0))
par(mai = c(0.4,0.2,0.4,0))
par(pin = c(5,4))
boxplot(APDdataByBeat , main=paste("APD distributions for each beat without outliers"), outline=FALSE, pars=list(ylab="APD (ms)",xlab="Beat number"))
dev.copy(png,"G:/PhD/Experiments/Bordeaux/Data/20131129/Baro005/APD50/APDDistByBeat_nooutliers.png",width=2480,height=1753,pointsize=12,res=300)
dev.off()

