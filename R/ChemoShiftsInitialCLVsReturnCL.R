#Load libraries
library("s20x")
library("nortest")

chemodata <- read.table("G:/PhD/Experiments/Auckland/InSituPrep/Statistics/ChemoCLandLocationData.csv", sep=",", header=TRUE)
chemodelCLPreIVB <- t(chemodata[which(chemodata$IVB==0),"CL2"]-chemodata[which(chemodata$IVB==0),"CL1"])
chemodelCLPostIVB <- t(chemodata[which(chemodata$IVB==1),"CL2"]-chemodata[which(chemodata$IVB==1),"CL1"])

#check normality
shapiro.test(chemodelCLPreIVB)
normcheck(chemodelCLPreIVB)

#construct confidence interval
t.test(chemodelCLPreIVB)

meandelCL <- mean(chemodelCLPreIVB)
meandelCL 
semdelCL <- sd(chemodelCLPreIVB)/sqrt(length(chemodelCLPreIVB))
semdelCL


returnchemodata <- read.table("G:/PhD/Experiments/Auckland/InSituPrep/Statistics/ChemoCLandLocationDataReturn.csv", sep=",", header=TRUE)
returnchemodelCLPreIVB <- t(returnchemodata[which(returnchemodata$IVB==0),"CL4"]-returnchemodata[which(returnchemodata$IVB==0),"CL3"])
returnchemodelCLPostIVB <- t(returnchemodata[which(returnchemodata$IVB==1),"CL4"]-returnchemodata[which(returnchemodata$IVB==1),"CL3"])

#check normality
shapiro.test(returnchemodelCLPreIVB)
normcheck(returnchemodelCLPreIVB)

t.test(returnchemodelCLPreIVB)

ListdelCLPre <- c(split(t(chemodelCLPreIVB),col(t(chemodelCLPreIVB))),split(t(returnchemodelCLPreIVB),col(t(returnchemodelCLPreIVB))))
ListdelCLPost <- c(split(t(chemodelCLPostIVB),col(t(chemodelCLPostIVB))),split(t(returnchemodelCLPostIVB),col(t(returnchemodelCLPostIVB))))

dev.new(width=5,height=5)
boxplot(ListdelCLPre , pars=list(ylab=expression(paste("Pre ",delta,"Cycle length (ms)"))))

dev.new(width=5,height=5)
boxplot(ListdelCLPost, pars=list(ylab=expression(paste("Post ",delta,"Cycle length (ms)"))))



