#Load libraries
library("s20x")
library("nortest")

barodata <- read.table("G:/PhD/Experiments/Auckland/InSituPrep/Statistics/BaroCLandLocationData.csv", sep=",", header=TRUE)
barodelCLPreIVB <- t(barodata[which(barodata$IVB==1),"CL2"]-barodata[which(barodata$IVB==1),"CL1"])
barodelCLPostIVB <- t(barodata[which(barodata$IVB==2),"CL2"]-barodata[which(barodata$IVB==2),"CL1"])
barodelPressure <- t(barodata[,"PlateauPressure"]-barodata[,"BaselinePressure"])

#normcheck(barodelCLPreIVB)
#shapiro.test(barodelCLPreIVB)

#compute mean and SEM
meanpressure <- mean(barodelPressure)
meanpressure
sempressure <- sd(barodelPressure)/sqrt(length(barodelPressure))
sempressure

barobaselinepressure <- t(barodata[,"BaselinePressure"])
meanpressure <- mean(barobaselinepressure)
meanpressure
sempressure <- sd(barobaselinepressure)/sqrt(length(barobaselinepressure))
sempressure

returnbarodata <- read.table("G:/PhD/Experiments/Auckland/InSituPrep/Statistics/BaroCLandLocationDataReturn.csv", sep=",", header=TRUE)
ReturnbarodelCLPreIVB <- t(returnbarodata [which(returnbarodata $IVB==1),"CL4"]-barodata[which(returnbarodata $IVB==1),"CL3"])	



#construct confidence interval
#t.test(barodelCLPreIVB)

chemodata <- read.table("G:/PhD/Experiments/Auckland/InSituPrep/Statistics/ChemoCLandLocationData.csv", sep=",", header=TRUE)
chemodelCLPreIVB <- t(chemodata[which(chemodata$IVB==1),"CL2"]-chemodata[which(chemodata$IVB==1),"CL1"])
chemodelCLPostIVB <- t(chemodata[which(chemodata$IVB==2),"CL2"]-chemodata[which(chemodata$IVB==2),"CL1"])
dev.new(width=8.27,height=5.845)
normcheck(chemodelCLPreIVB)
shapiro.test(chemodelCLPreIVB)

meandelCL <- mean(chemodelCLPreIVB)
meandelCL 
semdelCL <- sd(chemodelCLPreIVB)/sqrt(length(chemodelCLPreIVB))
semdelCL

#construct confidence interval
t.test(chemodelCLPreIVB)

#cchdata <- read.table("G:/PhD/Experiments/Auckland/InSituPrep/Statistics/CChCLandLocationData.csv", sep=",", header=TRUE)
#cchdelCLPreIVB <- t(cchdata[which(cchdata$IVB==1),"CL2"]-cchdata[which(cchdata$IVB==1),"CL1"])
#cchdelCLPostIVB <- t(cchdata[which(cchdata$IVB==2),"CL2"]-cchdata[which(cchdata$IVB==2),"CL1"])
#dev.new(width=8.27,height=5.845)
#normcheck(cchdelCLPreIVB)
#shapiro.test(cchdelCLPreIVB)

#construct confidence interval
#t.test(cchdelCLPreIVB)

