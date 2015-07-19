# An interface to data hosted online in Socrata data repositories
# 
# Author: Hugh J. Devlin, Ph. D. 2013-08-28
###############################################################################

# library('httr')       # for access to the HTTP header
# library('jsonlite')   # for parsing data types from Socrata
# library('mime')       # for guessing mime type

#' Wrap httr GET in some diagnostics
#' 
#' In case of failure, report error details from Socrata. For future: reconsider it.
#' 
#' @param url - Socrata Open Data Application Program Interface (SODA) query
#' @return httr response object
#' @importFrom httr http_status GET content stop_for_status
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
#' 
#' @noRd
checkResponse <- function(url) {
  response <- httr::GET(url)
  
  errorHandling(response)
  
  return(response)
}

#' Content parsers
#'
#' Return a data frame for csv or json
#'
#' @author Hugh J. Devlin \email{Hugh.Devlin@@cityofchicago.org}
#' @importFrom httr content
#' @param response - an httr response object
#' @return data frame, possibly empty
#' @noRd
getContentAsDataFrame <- function(response) {
  
  mimeType <- response$header$'content-type'
  
  # skip optional parameters
  sep <- regexpr(';', mimeType)[1]
  
  if(sep != -1) {
    mimeType <- substr(mimeType, 0, sep[1] - 1)
  }
  
  switch(mimeType,
         'text/csv' = 
           httr::content(response), # automatic parsing
         'application/json' = 
           if(httr::content(response, as = 'text') == "[ ]") { # empty json?
             data.frame() # empty data frame
           } else {
             data.frame(t(sapply(httr::content(response), unlist)), stringsAsFactors = FALSE)
           }
  ) 
  
}

#' Get the SoDA 2 data types
#'
#' Get the Socrata Open Data Application Program Interface data types from the http response header
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
#' @param response - headers attribute from an httr response object
#' @return a named vector mapping field names to data types
#' @importFrom jsonlite fromJSON
#' @noRd
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
#' @param app_token - a (non-required) string; SODA API token is used to query the data 
#' portal \url{http://dev.socrata.com/consumers/getting-started.html}
#' @return a data frame with POSIX dates
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
#' @examples
#' df <- read.socrata("http://soda.demo.socrata.com/resource/4334-bgaj.csv")
#' @importFrom httr parse_url build_url
#' @importFrom mime guess_type
#' 
#' @section TODO: \url{https://github.com/Chicago/RSocrata/issues/14}
#' 
#' \code{read.socrata(url, domain, fourbyfour, app_token, query)}
#' 
#' @export
read.socrata <- function(url, app_token = NULL) {
  validUrl <- validateUrl(url, app_token) # check url syntax, allow human-readable Socrata url
  parsedUrl <- httr::parse_url(validUrl)
  mimeType <- mime::guess_type(parsedUrl$path)
  
  if(!(mimeType %in% c('text/csv','application/json'))) {
    stop("Error in read.socrata: ", mimeType, " not a supported data format. Try JSON or CSV.")
  }
  
  response <- checkResponse(validUrl)
  page <- getContentAsDataFrame(response)
  result <- page
  dataTypes <- getSodaTypes(response)
  
  while (nrow(page) > 0) { # more to come maybe?
    query <- paste0(validUrl, ifelse(is.null(parsedUrl$query), '?', "&"), '$offset=', nrow(result))
    response <- checkResponse(query)
    page <- getContentAsDataFrame(response)
    result <- rbind(result, page) # accumulate
  }	
  
  # convert Socrata calendar dates to posix format
  for(columnName in colnames(page)[!is.na(dataTypes[fieldName(colnames(page))]) & dataTypes[fieldName(colnames(page))] == 'calendar_date']) {
    result[[columnName]] <- posixify(result[[columnName]])
  }
  
  return(result)
}

