# An interface to data hosted online in Socrata data repositories 
# 
# Author: Hugh J. Devlin, Ph. D. 2013-08-28
###############################################################################

library('httr') # for access to the HTTP header
library('rjson')

# Add CSV parser
assign("text/csv", function(x) {read.csv(textConnection(x), stringsAsFactors=FALSE)}, envir=httr:::parsers)
# Replace JSON parser
assign("application/json", function(x) data.frame(t(sapply(fromJSON(rawToChar(x)) , unlist)), stringsAsFactors=FALSE), envir=httr:::parsers)

#' Convert Socrata human-readable column name,
#' as appears in the first row of data,
#' to field name as appears in HTTP header
#'
#' @param humanName a Socrata human-readable column name
#' @return Socrata field name 
#' @export
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
#' @examples
#' fieldName("Number.of.Stations")
fieldName <- function(humanName) {
	tolower(gsub('\\.', '_', as.character(humanName)))	
}

#' Convert Socrata calendar_date string to POSIX
#'
#' Issue a time-stamped log message. 
#' @param x a string in Socrata calendar_date format
#' @return a POSIX date
#' @export
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
posixify <- function(x) {
	strptime(as.character(x), format="%m/%d/%Y %I:%M:%S %p")
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
#' earthquakesDataFrame <- read.socrata("http://soda.demo.socrata.com/resource/4tka-6guv.json")
read.socrata <- function(url) {
	url <- as.character(url)
	limit <- 1000
	offset <- 0
	response <- GET(url)
	stop_for_status(response)
	page <- content(response)
	result <- page
	dataTypes <- fromJSON(response$headers[['x-soda2-types']])
	names(dataTypes) <- fromJSON(response$headers[['x-soda2-fields']])
	while (nrow(page) == limit) { # more to come maybe?
		offset <- offset + limit # next page
		query <- paste(url, if(regexpr("\\?", url)[1] == -1){'?$offset='} else {"&$offset="}, offset, sep='')
		response <- GET(query)
		stop_for_status(response)
		page <- content(response)
		result <- rbind(result, page) # accumulate
	}	
	# convert Socrata calendar dates to posix format
	for(columnName in colnames(page)[!is.na(dataTypes[fieldName(colnames(page))]) & dataTypes[fieldName(colnames(page))] == 'calendar_date']) {
		result[[columnName]] <- posixify(result[[columnName]])
	}
	result
}
