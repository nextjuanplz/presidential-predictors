#Test analysis
#Juan M. Alzate Vanegas
#3-18-2018
####################################

#Initialize working directory
isPC = TRUE
mywd = ""
if(isPC) {
	mywd = "E:/Users/nextjuanplz/Dropbox/School/University of Central Florida/2017 - 2018/Spring 2018/STA 4164/Assignments/Oral Presentation"
} else {
	#For laptop use
	mywd = "C:/Users/juanm/Dropbox/School/University of Central Florida/2017 - 2018/Spring 2018/STA 4164/Assignments/Oral Presentation"
}
setwd(mywd)

#Read table with header
data <- read.csv("RElectionData.csv", header = TRUE)