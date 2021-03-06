#Load the s20x library
library("s20x")
graphics.off() 
routedir <- "G:/PhD/Experiments/Bordeaux/Data/20131129/1129baro006/APD50/"
#load the data
APDdata <- read.table(paste(c(routedir,"APDData.txt"),collapse=''), sep = ",", header = TRUE)
strSplitResult <- strsplit(routedir,"/")
aTitle <- tail(strSplitResult[[1]], n=2)
aTitle <- paste(c(aTitle[1], aTitle[2]), collapse=' ')
#Produce a boxplot of the CVdata by beat
APDdataByBeat <- t(APDdata[,1:ncol(APDdata)])
dev.new(width=8.27,height=5.845)
par(mar = c(0,0,0,0))
par(mai = c(0.4,0.2,0.4,0))
par(pin = c(5,4))
boxplot(APDdataByBeat , notch=TRUE, main=paste(aTitle, "\nAPD distributions for each beat"), pars=list(ylab="APD (ms)",xlab="Beat number"))
dev.copy(png,paste(c(routedir,"APDDistByBeat.png"),collapse=''),width=2480,height=1753,pointsize=12,res=300)
dev.off()
dev.new(width=8.27,height=5.845)
par(mar = c(0,0,0,0))
par(mai = c(0.4,0.2,0.4,0))
par(pin = c(5,4))
boxplot(APDdataByBeat , notch=TRUE, main=paste(aTitle, "\nAPD distributions for each beat without outliers"), outline=FALSE, pars=list(ylab="APD (ms)",xlab="Beat number"))
dev.copy(png,paste(c(routedir,"APDDistByBeat_nooutliers.png"),collapse=''),width=2480,height=1753,pointsize=12,res=300)
dev.off()

