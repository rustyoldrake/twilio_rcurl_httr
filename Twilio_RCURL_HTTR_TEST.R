##########################################################
## Using R Programming Language with Twilio REST API
## Basic Test Code - using HTTR and RCURL to send SMS Message from active (paid) account 
## Ryan Anderson - December 2014
## See also https://dreamtolearn.com//ryan/data_analytics_viz/80 
##########################################################

library(httr)
library(RCurl)

## The SID, TOKEN and From/To Numbers (you need to insert your own - "SAFE" obscures mine :)  )
Twilio_Account_SID <- "ACda5eedceab2a9aae6472320bdc54SAFE"
Twilio_Account_TOKEN <- "96ea43a811585a0f959675d1f951SAFE"
Number_From <- "+1240837SAFE"
Number_To <- "+1415672SAFE"

## WORKS -> HTTR Package using "POST"
the_url <- paste("https://api.twilio.com/2010-04-01/Accounts/",Twilio_Account_SID,"/Messages.XML",sep="")
POST(the_url,
     body = list(
       From = Number_From,
       To = Number_To,
       Body = "TWILIO TEST using R PROGRAMMING LANGUAGE - HTTR Package - Test #55"
     ),
     config=authenticate(Twilio_Account_SID,Twilio_Account_TOKEN,type="basic")
)


##########################################################

## WORKS - RCURL Package using PoSTFORM

## To begin: this line sets CERT Global to make a CA Cert go away - http://stackoverflow.com/questions/15347233/ssl-certificate-failed-for-twitter-in-r
options(RCurlOptions = list(
  cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"),
  httpauth=AUTH_BASIC
)
)
# NOTE - the "httpauth=AUTH_BASIC" piece gets rid of the "Error: UNAUTHORIZED" message (Thanks Twilio Alex)

the_url <- paste("https://api.twilio.com/2010-04-01/Accounts/",Twilio_Account_SID,"/Messages.XML",sep="")
postForm(the_url,
         .opts = list(
           userpwd = paste(Twilio_Account_SID,":",Twilio_Account_TOKEN,sep=""),
           useragent = "RCurl",
           verbose = TRUE
         ),
         .params = c(From = Number_From, 
                     To = Number_To, 
                     Body = "TWILIO TEST using R PROGRAMMING LANGUAGE - RCURL Package: POSTFORM Test #56" 
         )
)

