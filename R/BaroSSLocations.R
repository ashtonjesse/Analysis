#Load libraries
library("s20x")
library("nortest")

barodata <- read.table("G:/PhD/Experiments/Auckland/InSituPrep/Statistics/BaroSSLocations.csv", sep=",", header=FALSE)
baroPrimary <- t(barodata[barodata<2])

#check normality
shapiro.test(baroPrimary)
normcheck(baroPrimary)

baroCaudal <- t(barodata[barodata>=2])

#check normality
shapiro.test(baroCaudal)
normcheck(baroCaudal)
