# An interface to data hosted online in Socrata data repositories
# This is the main file which uses other functions to download data from a Socrata repositories
#
# Author: Hugh J. Devlin, Ph. D. 2013-08-28
###############################################################################

# library("httr")       # for access to the HTTP header
# library("jsonlite")   # for parsing data types from Socrata
# library("mime")       # for guessing mime type
# library("geojsonio") # for geospatial json

#' Wrap httr GET in some diagnostics
#' 
#' In case of failure, report error details from Socrata.
#' 
#' @param url - Socrata Open Data Application Program Interface (SODA) query, a URL
#' @return httr a response object
#' @importFrom httr GET
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
#' 
#' @noRd
checkResponse <- function(url = "") {
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
#' @importFrom geojsonio geojson_read
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
         "text/csv" = 
           httr::content(response), # automatic parsing
         "application/json" = 
           if(httr::content(response, as = "text") == "[ ]") { # empty json?
             data.frame() # empty data frame
           } else {
             data.frame(t(sapply(httr::content(response), unlist)), stringsAsFactors = FALSE)
           }, 
         "application/vnd.geo+json" =  # use geojson_read directly through its response link
           geojsonio::geojson_read(response$url, method = "local", parse = FALSE, what = "list")
  ) 
  
}

#' Get the SoDA 2 data types
#'
#' Get the Socrata Open Data Application Program Interface data types from the http response header
#' 
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
#' @description Manages throttling and POSIX date-time conversions.
#'
#' @param url - A Socrata resource URL, or a Socrata "human-friendly" URL, 
#' or Socrata Open Data Application Program Interface (SODA) query 
#' requesting a comma-separated download format (.csv suffix), 
#' May include SoQL parameters, and it is now assumed to include SODA \code{limit} 
#' & \code{offset} parameters.
#' Either use a compelete URL, e.g. \code{} or use parameters below to construct your URL. 
#' But don't combine them.
#' @param app_token - a (non-required) string; SODA API token can be used to query the data 
#' portal \url{http://dev.socrata.com/consumers/getting-started.html}
#' @param domain - A Socrata domain, e.g \url{http://data.cityofchicago.org} 
#' @param fourByFour - a unique 4x4 identifier, e.g. "ydr8-5enu". See more \code{\link{isFourByFour}}
#' @param query - Based on query language called the "Socrata Query Language" ("SoQL"), see 
#' \url{http://dev.socrata.com/docs/queries.html}.
#' @param limit - defaults to the max of 50000. See \url{http://dev.socrata.com/docs/paging.html}.
#' @param offset - defaults to the max of 0. See \url{http://dev.socrata.com/docs/paging.html}.
#' @param output - in case of building URL manually, one of \code{c("csv", "json", "geojson")}
#' 
#' @section TODO: \url{https://github.com/Chicago/RSocrata/issues/14}
#'
#' @return a data frame with POSIX dates
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
#' 
#' @examples
#' df <- read.socrata("http://soda.demo.socrata.com/resource/4334-bgaj.csv")
#' dfgjs <- read.socrata(url = "https://data.cityofchicago.org/resource/6zsd-86xi.geojson")
#' df2 <- read.socrata(domain = "http://data.cityofchicago.org", fourByFour = "ydr8-5enu")
#' 
#' @importFrom httr parse_url build_url
#' @importFrom mime guess_type
#' 
#' @export
read.socrata <- function(url = NULL, app_token = NULL, domain = NULL, fourByFour = NULL, 
                         query = NULL, limit = 50000, offset = 0, output = NULL) {
  
  # check url syntax, allow human-readable Socrata url
  validUrl <- validateUrl(url, app_token) 
  parsedUrl <- httr::parse_url(validUrl)
  mimeType <- mime::guess_type(parsedUrl$path, unknown = "application/vnd.geo+json")
  
  # match args
  output_args <- match.arg(output)
  
  if(!(mimeType %in% c("text/csv","application/json", "application/vnd.geo+json"))) {
    stop(mimeType, " not a supported data format. Try JSON, CSV or GeoJSON.")
  }
  
  response <- checkResponse(validUrl)
  page <- getContentAsDataFrame(response)
  result <- page
  
  if(mimeType %in% c("text/csv","application/json")) {
    dataTypes <- getSodaTypes(response)
  }
  
  ## More to come? Loop over pages implicitly
  ## TODO: start here
  while (nrow(page) > 0) { 
    query_url <- paste0(validUrl, ifelse(is.null(parsedUrl$query), "?", "&"), "$offset=", nrow(result))
    response <- checkResponse(query_url)
    page <- getContentAsDataFrame(response)
    result <- rbind(result, page) # accumulate
  }	
  
  # Convert Socrata calendar dates to POSIX format
  # Check for column names that are not NA and which dataType is a "calendar_date". If there are some, 
  # then convert them to POSIX format
  for(columnName in colnames(page)[!is.na(dataTypes[fieldName(colnames(page))]) & dataTypes[fieldName(colnames(page))] == "calendar_date"]) {
    result[[columnName]] <- posixify(result[[columnName]])
  }
  
  return(result)
}