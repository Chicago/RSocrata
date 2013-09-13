# An interface to data hosted online in Socrata data repositories 
# 
# Author: Hugh J. Devlin, Ph. D. 2013-08-28
###############################################################################

library('httr') # for access to the HTTP header
library('rjson')

# Customize httr content parsers
#
# Add csv support to httr and return a data frame for csv and json content
#
# @author Hugh J. Devlin \email{Hugh.Devlin@@cityofchicago.org}
assignParsers <- function() {
	
	# Add CSV parser
	assign("text/csv", 
			function(x) {
				read.csv(textConnection(x), stringsAsFactors=FALSE)
			}, 
			envir=httr:::parsers
	)
	
	# Replace JSON parser
	assign("application/json",
			function(x) {
				content = rawToChar(x)
				if(content=="[ ]") # empty JSON?
					data.frame() # empty data frame
				else
					data.frame(t(sapply(fromJSON(content), unlist)), stringsAsFactors=FALSE)
			}, 
			envir=httr:::parsers
	)
	
}

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
#' @param x a string in Socrata calendar_date format
#' @return a POSIX date
#' @export
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
posixify <- function(x) {
	strptime(as.character(x), format="%m/%d/%Y %I:%M:%S %p")
}

# Wrap httr GET in some diagnostics
# 
# In case of failure, report error details from Socrata
# 
# @param url Socrata Open Data Application Program Interface (SODA) query
# @return httr response object
# @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
get <- function(url) {
	response <- GET(url)
	status <- http_status(response)
	if(response$status_code != 200) {
		details <- content(response)
		if(nrow(details) > 0) {
			logMsg(paste("Error detail:", details$code[1], details$message[1]))
		}
	}
	stop_for_status(response)
	response
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
	assignParsers()
	response <- get(url)
	page <- content(response)
	result <- page
	# create a named vector mapping field names to data types
	dataTypes <- fromJSON(response$headers[['x-soda2-types']])
	names(dataTypes) <- fromJSON(response$headers[['x-soda2-fields']])
	while (nrow(page) > 0) { # more to come maybe?
		query <- paste(url, if(regexpr("\\?", url)[1] == -1){'?'} else {"&"}, '$offset=', nrow(result), sep='')
		response <- get(query)
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
