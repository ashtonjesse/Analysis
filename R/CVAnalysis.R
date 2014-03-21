#Load the s20x library
library("s20x")
graphics.off() 

routedir <- "G:/PhD/Experiments/Auckland/InSituPrep/20130816/0816vagus006/"
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
boxplot(CVdataByBeat, notch=TRUE, main=paste("CV distributions for each beat"), pars=list(ylab="CV (m/s)",xlab="Beat number"))
dev.copy(png,paste(c(routedir,"CVDistByBeat.png"),collapse=''),width=2480,height=1753,pointsize=12,res=300)
dev.off()
dev.new(width=8.27,height=5.845)
par(mar = c(0,0,0,0))
par(mai = c(0.4,0.2,0.4,0))
par(pin = c(5,4))
boxplot(CVdataByBeat, notch=TRUE, main=paste("CV distributions for each beat without outliers"), outline=FALSE, ylim=c(0,1.5), pars=list(ylab="CV (m/s)",xlab="Beat number"))
dev.copy(png,paste(c(routedir,"CVDistByBeat_nooutliers.png"),collapse=''),width=2480,height=1753,pointsize=12,res=300)
dev.off()

#Produce a boxplot of the CVdata by electrode group
#Group the electrode data by the connector number
nbeats <- nrow(CVdata)
nAcceptedElectrodes <- vector(mode="integer",length=length(ConnectorPatterns))
ConnectorDataAllBeats <- matrix(nrow=nbeats*nElectrodesPerConnector, ncol=nConnectors)
for (i in 1:length(ConnectorPatterns)) {	
	ThisConnector <- as.numeric(unlist(CVdata[grep(pattern=ConnectorPatterns[i],x=names(CVdata))]))
	ConnectorDataAllBeats[,i] <- c(ThisConnector, rep(NA, nbeats*nElectrodesPerConnector-length(ThisConnector)))
	nAcceptedElectrodes[i] <- length(ThisConnector)/nbeats
}	
ConnectorDataAllBeats <- data.frame(ConnectorDataAllBeats)
colnames(ConnectorDataAllBeats) <- ConnectorPatterns
nr<-6
nc<-2
dev.new(width=8.27,height=11.69)
par(oma = c( 0, 0, 3, 0 ) )
par(mfcol = c(nr,nc))
par(mar = c(0,0,0,0))
par(mai = c(0,0.2,0.4,0))
par(pin = c(1,1.2))
for (i in 6:2) {
	boxplot(ConnectorDataAllBeats[i], main=paste("CV distribution for connector",ConnectorPatterns[i],"n =",nAcceptedElectrodes[i]), outline=FALSE, ylim=c(0,1.4), pars=list(ylab="CV (m/s)"))
}
plot.new()
for (i in 12:7) {
	boxplot(ConnectorDataAllBeats[i], main=paste("CV distribution for connector",ConnectorPatterns[i],"n =",nAcceptedElectrodes[i]), outline=FALSE, ylim=c(0,1.4), pars=list(ylab="CV (m/s)"))
}
mtext( "CV distributions across all beats for n electrodes per connector", outer = TRUE )
dev.copy(png,filename=paste(c(routedir,"CVDistByLocation.png"),collapse=''),width=2480,height=3507,pointsize=12,res=300)
dev.off()

#Produce boxplots for each groups of beats

maxlength <- max(do.call(rbind, lapply(BeatGroups, length)))
ConnectorData <- matrix(nrow=maxlength*nElectrodesPerConnector, ncol=nConnectors)
ConnectorDataBeatGroups <- list(ConnectorData)
nAcceptedElectrodes <- vector(mode="integer",length=length(ConnectorPatterns))
for (j in 1:length(BeatGroups)) {
	for (i in 1:length(ConnectorPatterns)) {
		ThisBeatGroup <- as.numeric(unlist(CVdata[BeatGroups[[j]],grep(pattern=ConnectorPatterns[i],x=names(CVdata))]))
		ConnectorData[,i] <- c(ThisBeatGroup, rep(NA,maxlength*nElectrodesPerConnector-length(ThisBeatGroup)))
		nAcceptedElectrodes[i] <- length(ThisBeatGroup)
	}
ConnectorDataBeatGroups[[j]] <- ConnectorData
#Print out boxplots without outliers
df <- data.frame(ConnectorDataBeatGroups[[j]])
colnames(df) <- ConnectorPatterns
nr<-6
nc<-2
dev.new(width=8.27,height=11.69)
par(oma = c( 0, 0, 3, 0 ) )
par(mfcol = c(nr,nc))
par(mar = c(0,0,0,0))
par(mai = c(0,0.2,0.4,0))
par(pin = c(1,1.2))
for (i in 6:2) {
	boxplot(df[i], main=paste("CV distribution for connector",ConnectorPatterns[i],"n =",nAcceptedElectrodes[i]), outline=FALSE, ylim=c(0,1.4), pars=list(ylab="CV (m/s)"))
}
plot.new()
for (i in 12:7) {
	boxplot(df[i], main=paste("CV distribution for connector",ConnectorPatterns[i],"n =",nAcceptedElectrodes[i]), outline=FALSE, ylim=c(0,1.4), pars=list(ylab="CV (m/s)"))
}
mtext(paste("CV distributions across beats",BeatGroups[[j]][1],"to",BeatGroups[[j]][length(BeatGroups[[j]])]), outer = TRUE )
dev.copy(png,filename=paste(c(routedir,"CVDistByLocation_beatgroup",j,".png"),collapse=''),width=2480,height=3507,pointsize=12,res=300)
dev.off()

#Print out boxplots with outliers
dev.new(width=8.27,height=11.69)
par(oma = c( 0, 0, 3, 0 ) )
par(mfcol = c(nr,nc))
par(mar = c(0,0,0,0))
par(mai = c(0,0.2,0.4,0))
par(pin = c(1,1.2))
for (i in 6:2) {
	boxplot(df[i], main=paste("CV distribution for connector",ConnectorPatterns[i],"n =",nAcceptedElectrodes[i]), ylim=c(0,2.5), pars=list(ylab="CV (m/s)"))
}
plot.new()
for (i in 12:7) {
	boxplot(df[i], main=paste("CV distribution for connector",ConnectorPatterns[i],"n =",nAcceptedElectrodes[i]), ylim=c(0,2.5), pars=list(ylab="CV (m/s)"))
}
mtext(paste("CV distributions across beats",BeatGroups[[j]][1],"to",BeatGroups[[j]][length(BeatGroups[[j]])]), outer = TRUE )
dev.copy(png,filename=paste(c(routedir,"CVDistByLocation_beatgroup",j,"_outliers.png"),collapse=''),width=2480,height=3507,pointsize=12,res=300)
dev.off()
}

