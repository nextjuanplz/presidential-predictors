#Supplementary analysis

#Setup
#Initialize working directory
isPC = FALSE
mywd = ""
if(isPC) {
	#For desktop use
	mywd = "E:/Users/nextjuanplz/Dropbox/School/University of Central Florida/2017 - 2018/Spring 2018/STA 4164/Assignments/Oral Presentation"
} else {
	#For laptop use
	mywd = "C:/Users/juanm/Dropbox/School/University of Central Florida/2017 - 2018/Spring 2018/STA 4164/Assignments/Oral Presentation"
}
setwd(mywd)

#Read table with header
data <- read.csv("OutputData.csv", header = TRUE)
attach(data)

#Probit model
model <- formula("PredictiveOfWinner ~ Party + Party : State")
myprobit <- glm(model, family = binomial(link = "probit"), 
    data = data)
summary(myprobit)
myanova <- anova(myprobit, test="Chisq");myanova