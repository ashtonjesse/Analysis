#Load the s20x library
library("s20x")
graphics.off() 

#routedir <- "G:/PhD/Experiments/Bordeaux/Data/20131129/1129baro002/APD30/"
routedir <- "G:/PhD/Experiments/Auckland/InSituPrep/20130221/0221baro002/"
strSplitResult <- strsplit(routedir,"/")
aTitle <- tail(strSplitResult[[1]], n=2)
aTitle <- paste(c(aTitle[1], aTitle[2]), collapse=' ')
#load the data
CVdata <- read.table(paste(c(routedir,"CVData.txt"),collapse=''), sep = ",", header = TRUE)

#Enter case specific information
BeatGroups <- list(1:11,c(12:14,16:25),27:40)
ConnectorPatterns <- c("11.","12.","13.","14.","15.","16.","21.","22.","23.","24.","25.","26.")
nElectrodesPerConnector <- 24
nConnectors <- 12

#Produce a boxplot of the CVdata by beat
CVdataByBeat <- t(CVdata[,1:ncol(CVdata)])
dev.new(width=8.27,height=5.845)
par(mar = c(0,0,0,0))
par(mai = c(0.4,0.2,0.4,0))
par(pin = c(5,4))
boxplot(CVdataByBeat, notch=TRUE, main=paste(aTitle,"\nCV distributions for each beat"), pars=list(ylab="CV (m/s)",xlab="Beat number"))
dev.copy(png,paste(c(routedir,"CVDistByBeat.png"),collapse=''),width=2480,height=1753,pointsize=12,res=300)
dev.off()
dev.new(width=8.27,height=5.845)
par(mar = c(0,0,0,0))
par(mai = c(0.4,0.2,0.4,0))
par(pin = c(5,4))
boxplot(CVdataByBeat, notch=TRUE, main=paste(aTitle, "\nCV distributions for each beat without outliers"), outline=FALSE, ylim=c(0,1.5), pars=list(ylab="CV (m/s)",xlab="Beat number"))
dev.copy(png,paste(c(routedir,"CVDistByBeat_nooutliers.png"),collapse=''),width=2480,height=1753,pointsize=12,res=300)
dev.off()
