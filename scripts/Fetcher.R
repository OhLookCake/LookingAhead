
library(RCurl)

setwd('C:/etc/Projects/Data/_Ongoing/LookingAhead')

#Read login credentials from file
credentials <- readLines(con="login.txt",n=2)
username <- credentials[1]
password <- credentials[2]

#setup urls
loginURL 		<- "https://accounts.google.com/accounts/ServiceLogin"
authenticateURL <- "https://accounts.google.com/accounts/ServiceLoginAuth"
trendsURL 		<- "http://www.google.com/trends/TrendsReport?"


GetGALX <- function(curl) {
	## Gets the GALX cookie
	
	btg <- basicTextGatherer()
	curlPerform(url=loginURL, curl=curl, writefunction=btg$update, header=TRUE, ssl.verifypeer=FALSE)
	curlResult <- strsplit(btg$value(),"\n")[[1]]
	
	galx <- grep("Cookie: GALX", curlResult, value = TRUE)
	strsplit(galx,"[=;]")[[1]][2]
}


gLogin <- function(username, password) {
	#Logging in
	
	curlHandle <- getCurlHandle()
	
	ans <- (curlSetOpt(curl = curlHandle,
					   ssl.verifypeer = FALSE,
					   useragent = getOption('HTTPUserAgent', "R"),
					   timeout = 60,         
					   followlocation = TRUE,
					   cookiejar = "./cookies",
					   cookiefile = ""))
	
	galx <- GetGALX(curlHandle)
	authenticatePage <- postForm(authenticateURL, .params=list(Email=username, Passwd=password, GALX=galx, PersistentCookie="yes", continue="http://www.google.com/trends"), curl=curlHandle)
	
	authenticatePage2 <- getURL("http://www.google.com", curl=curlHandle)
	
	responseCode <- getCurlInfo(curlHandle)$response.code
	if(responseCode == 200) {
		cat("Login successful\n")
	} else {
		cat("Login failed. Response code: ", responseCode, "\n")
	}
	return(curlHandle)
}



TrendQuery <- function(q, availableRows=533, scale=0){
	#Actual Querying
	
	#533 is the number of weeks of data available as of time of running this.
	# When running at a later date, this number can be adjusted.
	# Better yet, use a formula using date() - <the starting date>
	
	#scale = 0: absolute, 1: relative
	
	g <- gLogin(username, password)
	qauthenticatePage2 <- getURL("http://www.google.com", curl=g)
	res <- getForm(trendsURL, q=q, content=1, export=1, graph="all_csv", scale = scale, curl=g)
	
	if( grepl("You have reached your quota limit", res)) {
		stop("Quota limit reached. Request denied.")
	} else {
		cat("Results fetched.\n")
	}
	
	x <- read.table(text=res, sep=",",skip=32, nrows=availableRows)
}
