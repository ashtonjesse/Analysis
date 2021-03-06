#Load the s20x library
library("s20x")
graphics.off() 
rm(list=ls(all=TRUE))

#routedir <- "F:/PhD/Experiments/Auckland/InSituPrep/20140630/20140630baro004/APD1/"
routedir <- "F:/PhD/Experiments/Auckland/InSituPrep/20140630/20140630baro004/APD1/"

strSplitResult <- strsplit(routedir,"/")
aTitle <- tail(strSplitResult[[1]], n=2)
aTitle <- paste(c(aTitle[1], aTitle[2]), collapse=' ')
#load the data
CVdata <- read.table(paste(c(routedir,"Beats12to46_CVData.txt"),collapse=''), sep = ",", header = TRUE)
iStartBeat=12;

#Produce a boxplot of the CVdata by beat
CVdataByBeat <- t(CVdata[,1:ncol(CVdata)])
dev.new(width=8.27,height=5.845)
par(mar = c(0,0,0,0))
par(mai = c(0.4,0.2,0.4,0))
par(pin = c(5,4))
boxplot(CVdataByBeat, notch=TRUE, main=paste(aTitle,"\nCV distributions for each beat"), pars=list(axes=FALSE,ylab="CV (m/s)",xlab="Beat number"))
axis(1, at=1:nrow(CVdata), labels = c((1:nrow(CVdata))+iStartBeat-1))
axis(2)
dev.copy(png,paste(c(routedir,"CVDistByBeat.png"),collapse=''),width=2480,height=1753,pointsize=12,res=300)
dev.off()
dev.new(width=8.27,height=5.845)
par(mar = c(0,0,0,0))
par(mai = c(0.4,0.2,0.4,0))
par(pin = c(5,4))
boxplot(CVdataByBeat, notch=TRUE, main=paste(aTitle, "\nCV distributions for each beat without outliers"), outline=FALSE, ylim=c(0,1.5), pars=list(axes=FALSE,ylab="CV (m/s)",xlab="Beat number"))
axis(1, at=1:nrow(CVdata), labels = c((1:nrow(CVdata))+iStartBeat-1))
axis(2)
dev.copy(png,paste(c(routedir,"CVDistByBeat_nooutliers.png"),collapse=''),width=2480,height=1753,pointsize=12,res=300)
dev.off()
