# An interface to Socrata online data publishing
# 
# Author: Hugh J. Devlin, Ph. D. 2013-08-28
###############################################################################

library('httr') # for access to the HTTP header

#' Convert Socrata human-readable column name, as appears in the first row of data, to field name as appears in HTTP header
#'
#' @param humanName a Socrata human-readable column name
#' @return Socrata field name 
#' @export
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
fieldName <- function(humanName) {
	tolower(gsub('\\.', '_', humanName))	
}

#' Trim the 1st and last characters from each element of a character vector
#'
#' @param x a character vector of length > 1
#' @return a character vector minus the 1st and last characters of each element
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
trimFirstAndLastChars <- function(x) {
	substr(x, 2, (nchar(x) - 1))
}

#' Parse a list from a Socrata SODA HTTP header
#'
#' @param s the value of the x-soda2-fieldss or x-soda2-types HTTP Header field
#' @return a character vector
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
parseXSodaList <- function(x) {
	c(sapply(strsplit(trimFirstAndLastChars(x), ','), trimFirstAndLastChars))
}

#' Convert Socrata calendar_date string to POSIX
#'
#' Issue a time-stamped log message. 
#' @param x a string in Socrata calendar_date format
#' @return a POSIX date
#' @export
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
posixify <- function(x) {
	strptime(x, format="%m/%d/%Y %I:%M:%S %p")
}

#' Get a full Socrata data set as an R data frame
#'
#' Handles throttling and POSIX date-time conversions
#'
#' @param url Socrata Open Data Application Program Interface (SODA) query, which may include SoQL parameters, but is assumed to not contain an offset parameter
#' @param ... additional arguments passed to read.csv
#' @return an R data frame with POSIX dates
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
read.socrata <- function(url, ...) {
	limit <- 1000
	offset <- 0
	response <- GET(url)
	page <- read.csv(textConnection(content(response)), stringsAsFactors=FALSE, ...)
	result <- page
	dataTypes <- parseXSodaList(response$headers[['x-soda2-types']])
	names(dataTypes) <- parseXSodaList(response$headers[['x-soda2-fields']])
	while (nrow(page) == limit) { # more to come maybe?
		offset <- offset + limit # next page
		query <- paste(url, if(regexpr("\\?", url)[1] == -1){'?'}, "&$offset=", offset, sep='')
		page <- read.csv(query, stringsAsFactors=FALSE, ...)
		result <- rbind(result, page) # accumulate
	}	
	# convert Socrata calendar dates to posix format
	for(colname in colnames(page)[dataTypes[fieldName(colnames(page))] == 'calendar_date']) {
		result[[colname]] <- posixify(result[[colname]])
	}
	result
}
