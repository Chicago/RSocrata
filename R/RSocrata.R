# An interface to data hosted online in Socrata data repositories 
# 
# Author: Hugh J. Devlin, Ph. D. 2013-08-28
###############################################################################

library('httr') # for access to the HTTP header
library('rjson')

#' Time-stamped message
#'
#' Issue a time-stamped, origin-stamped log message. 
#' @param s a string
#' @return None (invisible NULL) as per cat
#' @author Hugh J. Devlin \email{Hugh.Devlin@@cityofchicago.org}
logMsg <- function(s) {
	cat(format(Sys.time(), "%Y-%m-%d %H:%M:%OS3 "), as.character(sys.call(-1))[1], ": ", s, '\n', sep='')
}

#' Convert Socrata human-readable column name to field name
#' 
#' Convert Socrata human-readable column name,
#' as it might appear in the first row of data,
#' to field name as it might appear in the HTTP header;
#' that is, lower case, periods replaced with underscores#'
#' @param humanName a Socrata human-readable column name
#' @return Socrata field name 
#' @export
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
#' @examples
#' fieldName("Number.of.Stations") # number_of_stations
fieldName <- function(humanName) {
	tolower(gsub('\\.', '_', as.character(humanName)))	
}

#' Convert Socrata calendar_date string to POSIX
#'
#' @param x char in Socrata calendar_date format
#' @return a POSIX date
#' @export
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
posixify <- function(x) {
	x <- as.character(x)
	# Two calendar date formats supplied by Socrata
	if(regexpr("^[[:digit:]]{2}/[[:digit:]]{2}/[[:digit:]]{4}$", x[1])[1] == 1) 
		strptime(x, format="%m/%d/%Y")
	else
		strptime(x, format="%m/%d/%Y %I:%M:%S %p")
}

# Wrap httr GET in some diagnostics
# 
# In case of failure, report error details from Socrata
# 
# @param url Socrata Open Data Application Program Interface (SODA) query
# @return httr response object
# @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
getResponse <- function(url) {
	response <- GET(url)
	status <- http_status(response)
	if(response$status_code != 200) {
		details <- content(response)
		logMsg(paste("Error in httr GET:", details$code[1], details$message[1]))
	}
	stop_for_status(response)
	response
}

# Content parsers
#
# Return a data frame for csv and json
#
# @author Hugh J. Devlin \email{Hugh.Devlin@@cityofchicago.org}
# @param an httr response object
# @return data frame, possibly empty
getContentAsDataFrame <- function(response) { UseMethod('response') }
getContentAsDataFrame <- function(response) {
	mimeType <- response$header$'content-type'
	# skip optional parameters
	sep <- regexpr(';', mimeType)[1]
	if(sep != -1) mimeType <- substr(mimeType, 0, sep[1] - 1)
	switch(mimeType,
		'text/csv' = 
				read.csv(textConnection(content(response)), stringsAsFactors=FALSE),
		'application/json' = 
				if(content(response, as='text') == "[ ]") # empty json?
					data.frame() # empty data frame
				else
					data.frame(t(sapply(fromJSON(rawToChar(content(response, as='raw'))), unlist)), stringsAsFactors=FALSE)
	) # end switch
}

# Get the SoDA 2 data types
#
# Get the Socrata Open Data Application Program Interface data types from the http response header
# @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
# @param responseHeaders headers attribute from an httr response object
# @return a named vector mapping field names to data types
getSodaTypes <- function(response) { UseMethod('response') }
getSodaTypes <- function(response) {
	result <- fromJSON(response$headers[['x-soda2-types']])
	names(result) <- fromJSON(response$headers[['x-soda2-fields']])
	result
}

#' Get a full Socrata data set as an R data frame
#'
#' Manages throttling and POSIX date-time conversions
#'
#' @param url Socrata Open Data Application Program Interface (SODA) query, which may include SoQL parameters, but is assumed to not contain an offset parameter
#' @return an R data frame with POSIX dates
#' @export
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
#' @examples
#' earthquakes <- read.socrata("http://soda.demo.socrata.com/resource/4tka-6guv.json")
read.socrata <- function(url) {
	url <- as.character(url)
	parsedUrl <- parse_url(url)
	if(substr(parsedUrl$path, 1, 9) != 'resource/')
		stop("Error in read.socrata: url ", url, " is not a Socrata SoDA resource.")
	mimeType <- guess_media(parsedUrl$path)
	if(mimeType != 'text/csv' && mimeType != 'application/json')
		stop("Error in read.socrata: ", mimeType, " not a supported data format.")
	response <- getResponse(url)
	page <- getContentAsDataFrame(response)
	result <- page
	dataTypes <- getSodaTypes(response)
	while (nrow(page) > 0) { # more to come maybe?
		query <- paste(url, if(is.null(parsedUrl$query)) {'?'} else {"&"}, '$offset=', nrow(result), sep='')
		response <- getResponse(query)
		page <- getContentAsDataFrame(response)
		result <- rbind(result, page) # accumulate
	}	
	# convert Socrata calendar dates to posix format
	for(columnName in colnames(page)[!is.na(dataTypes[fieldName(colnames(page))]) & dataTypes[fieldName(colnames(page))] == 'calendar_date']) {
		result[[columnName]] <- posixify(result[[columnName]])
	}
	result
}
