# An interface to data hosted online in Socrata data repositories
# 
# Author: Hugh J. Devlin, Ph. D. 2013-08-28
###############################################################################

# library('httr')       # for access to the HTTP header
# library('jsonlite')   # for parsing data types from Socrata
# library('mime')       # for guessing mime type

#' Time-stamped message
#'
#' Issue a time-stamped, origin-stamped log message. 
#' @param s - a string
#' @return None (invisible NULL) as per cat
#' @author Hugh J. Devlin \email{Hugh.Devlin@@cityofchicago.org}
#' @noRd
logMsg <- function(s) {
	cat(format(Sys.time(), "%Y-%m-%d %H:%M:%OS3 "), as.character(sys.call(-1))[1], ": ", s, '\n', sep='')
}

#' Checks the validity of the syntax for a potential Socrata dataset Unique Identifier, also known as a 4x4.
#'
#' Will check the validity of a potential dataset unique identifier
#' supported by Socrata. It will provide an exception if the syntax
#' does not align to Socrata unique identifiers. It only checks for
#' the validity of the syntax, but does not check if it actually exists.
#' @param fourByFour - a string; character vector of length one
#' @return TRUE if is valid Socrata unique identifier, FALSE otherwise
#' @author Tom Schenk Jr \email{tom.schenk@@cityofchicago.org}
#' @export
isFourByFour <- function(fourByFour) {
	fourByFour <- as.character(fourByFour)
	if(nchar(fourByFour) != 9)
		return(FALSE)
	if(regexpr("[[:alnum:]]{4}-[[:alnum:]]{4}", fourByFour) == -1)
		return(FALSE)
	TRUE	
}

#' Convert, if necessary, URL to valid REST API URL supported by Socrata.
#'
#' Will convert a human-readable URL to a valid REST API call
#' supported by Socrata. It will accept a valid API URL if provided
#' by users and will also convert a human-readable URL to a valid API
#' URL. Will accept queries with optional API token as a separate
#' argument or will also accept API token in the URL query. Will
#' resolve conflicting API token by deferring to original URL.
#' @param url - a string; character vector of length one
#' @param app_token - a string; SODA API token used to query the data 
#' portal \url{http://dev.socrata.com/consumers/getting-started.html}
#' @return a - valid Url
#' @importFrom httr parse_url build_url
#' @author Tom Schenk Jr \email{tom.schenk@@cityofchicago.org}
#' @export
validateUrl <- function(url, app_token) {
	url <- as.character(url)
  parsedUrl <- httr::parse_url(url)
	if(is.null(parsedUrl$scheme) | is.null(parsedUrl$hostname) | is.null(parsedUrl$path))
		stop(url, " does not appear to be a valid URL.")
  if(!is.null(app_token)) { # Handles the addition of API token and resolves invalid uses
    if(is.null(parsedUrl$query[["$$app_token"]])) {
      token_inclusion <- "valid_use"
    } else {
      token_inclusion <- "already_included" }
    switch(token_inclusion,
      "already_included"={ # Token already included in url argument
        warning(url, " already contains an API token in url. Ignoring user-defined token.")
      },
      "valid_use"={ # app_token argument is used, not duplicative.
        parsedUrl$query[["app_token"]] <- as.character(paste("%24%24app_token=", app_token, sep=""))
      })
  } 
  if(substr(parsedUrl$path, 1, 9) == 'resource/') {
		return(httr::build_url(parsedUrl)) # resource url already
	}
	fourByFour <- basename(parsedUrl$path)
  if(!isFourByFour(fourByFour))
		stop(fourByFour, " is not a valid Socrata dataset unique identifier.")
  else {
    parsedUrl$path <- paste('resource/', fourByFour, '.csv', sep="")
    httr::build_url(parsedUrl) 
  }
}

#' Convert Socrata human-readable column name to field name
#' 
#' Convert Socrata human-readable column name,
#' as it might appear in the first row of data,
#' to field name as it might appear in the HTTP header;
#' that is, lower case, periods replaced with underscores#'
#' @param humanName - a Socrata human-readable column name
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
#' @param x - character vector in one of two Socrata calendar_date formats
#' @return a POSIX date
#' @export
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
posixify <- function(x) {
	x <- as.character(x)
	if (length(x)==0) return(x)
	# Two calendar date formats supplied by Socrata
	if(any(regexpr("^[[:digit:]]{1,2}/[[:digit:]]{1,2}/[[:digit:]]{4}$", x[1])[1] == 1))
	  strptime(x, format="%m/%d/%Y") # short date format
	else
	  strptime(x, format="%m/%d/%Y %I:%M:%S %p") # long date-time format 
}

#' Wrap httr GET in some diagnostics
#' 
#' In case of failure, report error details from Socrata
#' 
#' @param url - Socrata Open Data Application Program Interface (SODA) query
#' @return httr response object
#' @importFrom httr http_status GET content stop_for_status
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
#' @noRd
getResponse <- function(url) {
	response <- httr::GET(url)
	# status <- httr::http_status(response)
	if(response$status_code != 200) {
		msg <- paste("Error in httr GET:", response$status_code, response$headers$statusmessage, url)
		if(!is.null(response$headers$`content-length`) && (response$headers$`content-length` > 0)) {
			details <- httr::content(response)
			msg <- paste(msg, details$code[1], details$message[1])	
		}
		logMsg(msg)
	}
	httr::stop_for_status(response)
	return(response)
}

#' Content parsers
#'
#' Return a data frame for csv
#'
#' @author Hugh J. Devlin \email{Hugh.Devlin@@cityofchicago.org}
#' @importFrom httr content
#' @param response - an httr response object
#' @return data frame, possibly empty
#' @noRd
getContentAsDataFrame <- function(response) { UseMethod('response') }
getContentAsDataFrame <- function(response) {
	mimeType <- response$header$'content-type'
	# skip optional parameters
	sep <- regexpr(';', mimeType)[1]
	if(sep != -1) mimeType <- substr(mimeType, 0, sep[1] - 1)
	switch(mimeType,
		'text/csv' = 
				content(response), # automatic parsing
		'application/json' = 
				if(content(response, as='text') == "[ ]") # empty json?
					data.frame() # empty data frame
				else
					data.frame(t(sapply(content(response), unlist)), stringsAsFactors=FALSE)
	) # end switch
}

#' Get the SoDA 2 data types
#'
#' Get the Socrata Open Data Application Program Interface data types from the http response header
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
#' @param response - headers attribute from an httr response object
#' @return a named vector mapping field names to data types
#' @importFrom jsonlite fromJSON
#' @noRd
getSodaTypes <- function(response) { UseMethod('response') }
getSodaTypes <- function(response) {
	result <- jsonlite::fromJSON(response$headers[['x-soda2-types']])
	names(result) <- jsonlite::fromJSON(response$headers[['x-soda2-fields']])
	return(result)
}

#' Get a full Socrata data set as an R data frame
#'
#' Manages throttling and POSIX date-time conversions
#'
#' @param url - A Socrata resource URL, 
#' or a Socrata "human-friendly" URL, 
#' or Socrata Open Data Application Program Interface (SODA) query 
#' requesting a comma-separated download format (.csv suffix), 
#' May include SoQL parameters, 
#' but is assumed to not include a SODA offset parameter
#' @param app_token - a string; SODA API token used to query the data 
#' portal \url{http://dev.socrata.com/consumers/getting-started.html}
#' @return an R data frame with POSIX dates
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
#' @examples
#' df <- read.socrata("http://soda.demo.socrata.com/resource/4334-bgaj.csv")
#' @importFrom httr parse_url build_url
#' @importFrom mime guess_type
#' @export
read.socrata <- function(url, app_token = NULL) {
	validUrl <- validateUrl(url, app_token) # check url syntax, allow human-readable Socrata url
	parsedUrl <- httr::parse_url(validUrl)
	mimeType <- mime::guess_type(parsedUrl$path)
	if(!(mimeType %in% c('text/csv','application/json')))
		stop("Error in read.socrata: ", mimeType, " not a supported data format.")
	response <- getResponse(validUrl)
	page <- getContentAsDataFrame(response)
	result <- page
	dataTypes <- getSodaTypes(response)
	while (nrow(page) > 0) { # more to come maybe?
		query <- paste(validUrl, if(is.null(parsedUrl$query)) {'?'} else {"&"}, '$offset=', nrow(result), sep='')
		response <- getResponse(query)
		page <- getContentAsDataFrame(response)
		result <- rbind(result, page) # accumulate
	}	
	# convert Socrata calendar dates to posix format
	for(columnName in colnames(page)[!is.na(dataTypes[fieldName(colnames(page))]) & dataTypes[fieldName(colnames(page))] == 'calendar_date']) {
		result[[columnName]] <- posixify(result[[columnName]])
	}
	return(result)
}

#' List datasets available from a Socrata domain
#'
#' @param url - A Socrata URL. This simply points to the site root. 
#' @return an R data frame containing a listing of datasets along with
#' various metadata.
#' @author Peter Schmiedeskamp \email{pschmied@@uw.edu}
#' @examples
#' df <- ls.socrata("http://soda.demo.socrata.com")
#' @importFrom jsonlite fromJSON
#' @importFrom httr parse_url
#' @export
ls.socrata <- function(url) {
    url <- as.character(url)
    parsedUrl <- httr::parse_url(url)
    if(is.null(parsedUrl$scheme) | is.null(parsedUrl$hostname))
        stop(url, " does not appear to be a valid URL.")
    parsedUrl$path <- "data.json"
    df <- jsonlite::fromJSON(httr::build_url(parsedUrl))
    df <- as.data.frame(df$dataset)
    df$issued <- as.POSIXct(df$issued)
    df$modified <- as.POSIXct(df$modified)
    df$theme <- as.character(df$theme)
    return(df)
}
