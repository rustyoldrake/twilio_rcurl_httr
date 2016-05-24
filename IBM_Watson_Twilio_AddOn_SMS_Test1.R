######################################################
### Experimental Code.  Experimental R Interface for IBM Watson Services & Twilio  May 2016 
### Focus: IBM Watson - Alchemy Language integrated with Twilio SMS
### Focus: TWILIO - https://www.twilio.com/ - apps to communicate with the world
### Watson Services: http://www.ibm.com/smarterplanet/us/en/ibmwatson/developercloud/services-catalog.html
### https://github.com/rustyoldrake/R_Scripts_for_Watson - Ryan Anderson  - this is my test code.  Use at your own peril!  Representations do not necessarily represent the views of my employer
######################################################

library(RCurl) # General Network Client Interface for R
library(rjson) # JSON for R
library(jsonlite) # JSON parser
library(XML) # XML parser
library(httr) # Tools for URLs and HTTP

options(RCurlOptions = list(cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"))) ## sets CERT Global to make a CA Cert go away - http://stackoverflow.com/questions/15347233/ssl-certificate-failed-for-twitter-in-r

######### Housekeeping And Authentication 
setwd("/Users/ryan/Documents/Partners/Twilio/public")
getwd()
source("keys.R") # this files is where you put your Watson & Twilio Access Credentials from Bluemix (username and password)

## check we got FOUR ITEMS: authentication and phone numbers
AccountSID_TWILIO # confirm SID is here from Keys. R file (you need to sign up to Twilio and get keys)
AuthToken_TWILIO # Check you have Token - sign up here if not https://www.twilio.com - looks like this "96ea43a811585a0f9596999999"
NUMBER_FROM # check it's looking ok - you can buy this for $1 on twilio - looks like this "+1650799999"
NUMBER_TO # check it's looking ok - https://www.twilio.com/console/phone-numbers/incoming  - looks like this "+1650799999"

######## STEP #1 - Confirm Credentails work and API is responding happily
getURL("https://api.twilio.com/2010-04-01")  # working? - get's a response - generic/public
httpGET("https://api.twilio.com/2010-04-01")  # working?
GET("https://api.twilio.com/2010-04-01")  # working? yes - 200 response

### Authenticate with Twilio Credentials
ABC_authenticate_twilio <- paste("https://",AccountSID_TWILIO,":",AuthToken_TWILIO,"@api.twilio.com/2010-04-01/Accounts",sep="")
authenticate_response <- getURL(ABC_authenticate_twilio)
print(authenticate_response)  ## if this work, you should get a long string that contains something like "<FriendlyName>ryan###@gmail.com's Account

getURL(paste("https://api.twilio.com/2010-04-01/Accounts/",AccountSID_TWILIO,"/Messages.JSON",sep=""),userpwd = paste(AccountSID_TWILIO,":",AuthToken_TWILIO,sep=""))
GET(ABC_authenticate_twilio) # this work too? 200 yes?

######## STEP #2 - Let's send an SMS Text
ABC_post_twilio <- paste("https://",AccountSID_TWILIO,":",AuthToken_TWILIO,"@api.twilio.com/2010-04-01/Accounts/",AccountSID_TWILIO,"/Messages.XML",sep="")
ABC_post_twilio # look good?

########## THIS FUNCTION Receives query/message and also emotion and pushes out to SMS/MMS via twilio
##########   TESTING SCRIPT

message <- NULL
message[1] <- "Let's go to the store in Oakland and buy a Ford Mustang"
message[2] <- "Did you drink the Kokanee Beer from Cranbrook BC? Nice eh?"
message[3] <- "I'm really angry about the poor state of roads in New York City"
message[4] <- "Hi!  I vote yes!  Sally was a great singer!  I love Bon Jovi"
message[5] <- "Carrots apples and pears are nice for a salad"
message[6] <- "President Obama is President of USA.  Justin Trudeau is PM of Canada."
message[7] <- "Chocolate Cake is delicious"
message[8] <- "I'm not happy with that thing.  Very very dissapointed.  I'm a terrific negotiator"
message[9] <- "What a glorious day!  Love the weather.  Of to Chez Panisse soon! Yay"
message[10] <- "Can you have GE customer service call me about my toaster? It's smoking and on fire"

for(i in 1:10)
{
  ptm <- proc.time()

  response <- POST(ABC_post_twilio, 
       body = list(
         From = NUMBER_FROM, To = NUMBER_TO,
         Body = paste("Test#",i,": ",message[i],sep="")
       ))
  temp <- proc.time() - ptm
  print(paste("test #",i," : ",round(temp[3]*1000,2),"ms - ",message[i],sep=""))
  print(response$times)
}


# response$url
# response$status_code
# response$all_headers
# response$headers
# response$times

#####

message <- read.csv("SMS_multi_language.csv")
message[100,1]
dim(message)

for(i in 1:25)
{
  print(paste("Test #",i," SMS: ",message[i,1],sep=""))
  POST(ABC_post_twilio, 
       body = list(
         From = NUMBER_FROM, To = NUMBER_TO,
         Body = paste("Test ",i,": ",message[i,1],sep="")
       ))
}



########

