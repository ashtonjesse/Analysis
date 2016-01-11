#Load libraries
library("s20x")
library("nortest")

barodata <- read.table("G:/PhD/Experiments/Auckland/InSituPrep/Statistics/BaroCLandLocationData.csv", sep=",", header=TRUE)
barodelCLPreIVB <- t(barodata[which(barodata$IVB==1),"CL2"]-barodata[which(barodata$IVB==1),"CL1"])
barodelCLPostIVB <- t(barodata[which(barodata$IVB==2),"CL2"]-barodata[which(barodata$IVB==2),"CL1"])

#check normality
shapiro.test(barodelCLPreIVB)
normcheck(barodelCLPreIVB)

#construct confidence interval
t.test(barodelCLPreIVB)

returnbarodata <- read.table("G:/PhD/Experiments/Auckland/InSituPrep/Statistics/BaroCLandLocationDataReturn.csv", sep=",", header=TRUE)
returnbarodelCLPreIVB <- t(returnbarodata[which(returnbarodata$IVB==1),"CL4"]-returnbarodata[which(returnbarodata$IVB==1),"CL3"])
returnbarodelCLPostIVB <- t(returnbarodata[which(returnbarodata$IVB==2),"CL4"]-returnbarodata[which(returnbarodata$IVB==2),"CL3"])

#check normality
shapiro.test(returnbarodelCLPreIVB)
normcheck(returnbarodelCLPreIVB)

t.test(returnbarodelCLPreIVB)

ListdelCLPre <- c(split(t(barodelCLPreIVB),col(t(barodelCLPreIVB))),split(t(returnbarodelCLPreIVB),col(t(returnbarodelCLPreIVB))))
ListdelCLPost <- c(split(t(barodelCLPostIVB),col(t(barodelCLPostIVB))),split(t(returnbarodelCLPostIVB),col(t(returnbarodelCLPostIVB))))

dev.new(width=5,height=5)
boxplot(ListdelCLPre , pars=list(ylab=expression(paste("Pre ",delta,"Cycle length (ms)"))))

dev.new(width=5,height=5)
boxplot(ListdelCLPost, pars=list(ylab=expression(paste("Post ",delta,"Cycle length (ms)"))))



