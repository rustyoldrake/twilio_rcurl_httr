##########################################################
## Using R Programming Language with SIGNAL WIRE REST API
## https://signalwire.com/
## SIGNAL WIRE is a lot like TWILIO - so I'm seeing if I can reuse code from a few years ago 
## Basic Test Code - using HTTR and RCURL to send SMS Message from active (paid) account 
##########################################################

library(httr)
library(RCurl)

## The SID, TOKEN and From/To Numbers (you need to insert your own - "SAFE" obscures mine :)  )
SignalWire_PROJECT_ID <- "a8a7a293-5a5e-XXXX-XXXXXXXX" # aka SID ID or Account SID
SignalWire_API_Token <- "PT93c1d9420e33a5119050XXXXXXXXX"


SignalWire_Phone_Number_ORIGIN_PHONE_NUMBER <- "+1707XXXXXXX" # Good Dogs Are Nice
SignalWire_Phone_Number_TARGET_OUTBOUND <- "+1415XXXXXXX" # my cell for testing
SignalWire_Base_URL <- "https://rustyoldrake.signalwire.com/api/laml/2010-04-01/"

# Command Line Curl # https://docs.signalwire.com/laml-api/#laml-rest-api-overview-base-url
# works # curl https://rustyoldrake.signalwire.com/api/laml/2010-04-01/Accounts -X GET -u "a8a7a293-5a5e-4d42-xxxxx:PT93c1d9420e33a51xxxx"

## To begin: this line sets CERT Global to make a CA Cert go away - http://stackoverflow.com/questions/15347233/ssl-certificate-failed-for-twitter-in-r
options(RCurlOptions = list(
  cainfo = system.file("CurlSSL", "cacert.pem", package = "RCurl"),
  httpauth=AUTH_BASIC))


### 1 #### BASIC AUTHENTICATION 
# works # GET(paste(SignalWire_Base_URL,"Accounts",sep=""),authenticate(SignalWire_PROJECT_ID, SignalWire_API_Token))

process_signalwire_authenticate <- function(){
  raw_response <- GET(paste(SignalWire_Base_URL,"Accounts",sep=""),
                authenticate(SignalWire_PROJECT_ID, SignalWire_API_Token))
  return(content(raw_response))
}

response <- process_signalwire_authenticate()

# What did we get in our payload?
response
response$uri  #"/api/laml/2010-04-01/Accounts?Page=1&PageSize=50"
response$accounts
response$accounts[[1]]$friendly_name # [1] "rustyoldrake"
response$accounts[[1]]$sid  # our SignalWire_PROJECT_ID 
response$accounts[[1]]$date_created  # [1] "Fri, 26 Oct 2018 04:42:19 +0000"

SignalWire_AccountSID <- response$accounts[[1]]$sid  # this is same as Project ID above, but maybe not always :)

### 2 ### Lets' send an SMS
# curl https://rustyoldrake.signalwire.com/api/laml/2010-04-01/Accounts/a8a7a293-5a5e-xxxx/Messages.json -X POST --data-urlencode "From=+1707xxx" --data-urlencode "Body=Hello World 2" --data-urlencode "To=+1415xxxx" -u "a8a7a293-5a5e-4d42-xxxx:PT93c1d9420e33a51190503xxx" 
# works
# the_url <- paste("https://rustyoldrake.signalwire.com/api/laml/2010-04-01/Accounts/",SignalWire_AccountSID,"/Messages.XML",sep="")


process_signalwire_send_SMS <- function(sms_text){
    raw_response <- POST(paste("https://rustyoldrake.signalwire.com/api/laml/2010-04-01/Accounts/",
                           SignalWire_AccountSID,
                           "/Messages.XML",
                           sep=""),
                         body = list(
                           From = SignalWire_Phone_Number_ORIGIN_PHONE_NUMBER,
                           To = SignalWire_Phone_Number_TARGET_OUTBOUND,
                           Body = sms_text # url encode not needed (?)
                           ),
                        config=authenticate(SignalWire_PROJECT_ID,SignalWire_API_Token,type="basic")
                      )
    return(content(raw_response))
}
response <- process_signalwire_send_SMS("Hello world 13")  # works
response
## 

### Above here stuff works OK - below is work in progress 
  
  
### 2b ### WARNING - below NOT WORKING RELIABLY (but curl worked a bit)
### 2b ### let's have some fun and try to repurpose:
#### https://github.com/rustyoldrake/R_Scripts_for_Watson/blob/master/Watson-TWILIO-Code-Snippet.R
  
  process_signalwire_send_MMS <- function(emotion, sms_text){
    
    switch(emotion,
           "joy" = image_link <- "https://dreamtolearn.com/internal/doc-asset/251BS61FR6H557318H0CS0YLS/joy.jpg",
           "sadness" = image_link <- "https://dreamtolearn.com/internal/doc-asset/251BS61FR6H557318H0CS0YLS/sad.jpg",
           "anger" = image_link <- "https://dreamtolearn.com/internal/doc-asset/251BS61FR6H557318H0CS0YLS/anger.jpg",
           "disgust" = image_link <- "https://dreamtolearn.com/internal/doc-asset/251BS61FR6H557318H0CS0YLS/disgust.jpg",
           "fear" = image_link <- "https://dreamtolearn.com/internal/doc-asset/251BS61FR6H557318H0CS0YLS/fear.jpg"
    )  
    
    raw_response <- POST(paste("https://rustyoldrake.signalwire.com/api/laml/2010-04-01/Accounts/",
                               SignalWire_AccountSID,
                               "/Messages.XML",
                               sep=""),
                         body = list(
                           From = SignalWire_Phone_Number_ORIGIN_PHONE_NUMBER,
                           To = SignalWire_Phone_Number_TARGET_OUTBOUND,
                           Body = sms_text, 
                           MediaUrl = image_link
                           ),
                         config=authenticate(SignalWire_PROJECT_ID,SignalWire_API_Token,type="basic")
                        )
    return(content(raw_response))
  }
  
  #Test - fail
  process_signalwire_send_MMS("joy","joy joy") # doesnt work as hoped (MediaURL)
  
  # so here's a work around
  process_signalwire_send_MMS("ignore","https://dreamtolearn.com/internal/doc-asset/251BS61FR6xxxxxx/joy.jpg")
  process_signalwire_send_MMS("ignore","JOY!  This test of SignalWire APIs works!")
  response
  
  

### 3 ### WARNING - below NOT WORKING RELIABLY (but curl worked a bit)
### 3 #### LET'S DO A TEST VOICE CALL - per https://docs.signalwire.com/laml-api/#api-reference-calls-create-a-call

#SignalWire_Phone_Number_ORIGIN_PHONE_NUMBER <- "+xxxx" # Black Cats Are Nice
#SignalWire_Phone_Number_TARGET_OUTBOUND <- "+xxxx" # my cell for testing

process_signalwire_make_CALL <- function(){
  raw_response <- POST(paste("https://rustyoldrake.signalwire.com/api/laml/2010-04-01/Accounts/",
                             SignalWire_AccountSID,
                             "/Calls.json",
                             sep=""),
                       body = list(
                         From = SignalWire_Phone_Number_ORIGIN_PHONE_NUMBER,
                         To = SignalWire_Phone_Number_TARGET_OUTBOUND,
                         Url = "https://rustyoldrake.signalwire.com/docs/voice.xml"
                       ),
                       config=authenticate(SignalWire_PROJECT_ID,SignalWire_API_Token,type="basic")
                      )
  return(content(raw_response))
}
response <- process_signalwire_make_CALL()
response


### 4 ### OK Let's do " List All Queue Members" https://docs.signalwire.com/laml-api/#api-reference-queue-members-list-all-queue-members
### The ability to read all of the queue members that are waiting in a particular queue. This will be returned as a list of members.

# works ish # curl https://rustyoldrake.signalwire.com/api/laml/2010-04-01/Accounts/a8a7a293-5a5e-xxxxx/Queues.json -X GET -u "a8a7a293-5a5e-4d42-xxxxx-xxxxx:xxxxxx"

process_signalwire_get_queue <- function(){
  raw_response <- GET(paste(SignalWire_Base_URL,"Accounts",sep=""),
                      authenticate(SignalWire_PROJECT_ID, SignalWire_API_Token))
  return(content(raw_response))
}
process_signalwire_get_queue()

