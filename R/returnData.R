# An interface to data hosted online in Socrata data repositories
# This is the main file which uses other functions to download data from a Socrata repositories
#
# Author: Hugh J. Devlin, Ph. D. et al.
###############################################################################

#' Converts to data frame even with missing columns
#' 
#' @source https://github.com/DASpringate/RSocrata/blob/master/R/RSocrata.R#L130
#' @source https://github.com/Chicago/RSocrata/pull/3/files
#' 
#' If all items are of the same length, just goes ahead and converts to df.
#' If the items are of different lengths, assume the longest has all the columns,
#' fill in the gaps with NA in the other columns and return in the original column order.
#' 
#' @param con - a list as output by content(response)
#' @return a dataframe
#' @author David A Springate \email{daspringate@@gmail.com}
#' @noRd
content_to_df <- function(con){
  lengths <- sapply(con, length)
  if (all(lengths == length(con[[1]]))) {
    data.frame(t(sapply(con, unlist)), stringsAsFactors = FALSE)
  } else {
    all_cols <- names(con[[which(sapply(con, length) == max(sapply(con, length)))[1]]])
    con <- lapply(con, function(x) {
      r <- c(x, sapply(all_cols[!all_cols %in% names(x)], function(xx) NA, simplify = FALSE))
      r[all_cols]
    })
    data.frame(t(sapply(con, unlist)), stringsAsFactors = FALSE)
  }
}

#' Content parsers
#'
#' Return a data frame for csv or json. GeoJSON is used extra in its own function. 
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
  
  if (sep != -1) {
    mimeType <- substr(mimeType, 0, sep[1] - 1)
  }
  
  switch(mimeType,
         "text/csv" = 
           httr::content(response), # automatic parsing
         "application/json" = 
           if (httr::content(response, as = "text") == "[ ]") { # empty json?
             data.frame() # empty data frame
           } else {
             content_to_df(httr::content(response))
           }
  ) 
  
}


#' Get a full Socrata data set as an R data frame
#'
#' @description Manages throttling and POSIX date-time conversions. We support only .json suffix.
#'
#' @param url - A Socrata resource URL, or a Socrata "human-friendly" URL, 
#' or Socrata Open Data Application Program Interface (SODA) query 
#' requesting a comma-separated download format (.json suffix), 
#' May include SoQL parameters, and it is now assumed to include SODA \code{limit} 
#' & \code{offset} parameters.
#' Either use a compelete URL or use parameters below to construct your URL. 
#' @param app_token - a (non-required) string; SODA API token can be used to query the data 
#' portal \url{http://dev.socrata.com/consumers/getting-started.html}
#' @param query - Based on query language called the "Socrata Query Language" ("SoQL"), see 
#' \url{http://dev.socrata.com/docs/queries.html}.
#' @param limit - defaults to the max of 50000. See \url{http://dev.socrata.com/docs/paging.html}.
#' @param domain - A Socrata domain, e.g \url{http://data.cityofchicago.org} 
#' @param fourByFour - a unique 4x4 identifier, e.g. "ydr8-5enu". See more \code{\link{isFourByFour}}
#' 
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
#' 
#' @examples
#' \dontrun{
#' df_1 <- read.socrata(url = "http://soda.demo.socrata.com/resource/4334-bgaj.csv")
#' df_2 <- read.socrata(domain = "http://data.cityofchicago.org/", fourByFour = "ydr8-5enu")
#' df_3 <- read.socrata(url = "http://data.cityofchicago.org/resource/ydr8-5enu.json")
#' }
#' @importFrom httr parse_url
#' @importFrom plyr rbind.fill
#' 
#' @export
read.socrata <- function(url = NULL, app_token = NULL, limit = 50000, domain = NULL, fourByFour = NULL, 
                         query = NULL) {
  
  if (is.null(url) == TRUE) {
    buildUrl <- paste0(domain, "/resource/", fourByFour, ".json")
    url <- httr::parse_url(buildUrl)
  }
  
  # check url syntax, allow human-readable Socrata url
  validUrl <- validateUrl(url) 
  parsedUrl <- httr::parse_url(validUrl)
  
  response <- errorHandling(validUrl, app_token)
  results <- getContentAsDataFrame(response)
  dataTypes <- getSodaTypes(response)
  
  rowCount <- as.numeric(getQueryRowCount(validUrl))

  ## More to come? Loop over pages implicitly
  while (nrow(results) < rowCount) { 
    query_url <- paste0(validUrl, ifelse(is.null(parsedUrl$query), "?", "&"), "$offset=", nrow(results), "&$limit=", limit)
    response <- errorHandling(query_url, app_token)
    page <- getContentAsDataFrame(response)
    results <- plyr::rbind.fill(results, page) # accumulate data
  }	
  
  # Convert Socrata calendar dates to POSIX format
  # If sodaTypes are not null, check for column names that are not NA and which dataType 
  # is a "calendar_date". If there are some, then convert them to POSIX format
  if (!is.null(dataTypes)) {
    for (columnName in colnames(results)[!is.na(dataTypes[fieldName(colnames(results))]) 
                                         & dataTypes[fieldName(colnames(results))] == "calendar_date"]) {
      results[[columnName]] <- posixify(results[[columnName]])
    }
  }
  
  return(results)
}


#' Download GeoJSON data using geojsonio package
#'
#' @param ... - other arguments from \link{geojsonio} package for geojson_read method
#' @param url - A Socrata resource URL, requiring a .geojson suffix.
#' 
#' @return Returns a list, which is the default option here. 
#'
#' @examples 
#' \dontrun{
#' df_geo <- read.socrataGEO(url = "https://data.cityofchicago.org/resource/6zsd-86xi.geojson")
#' }
#' 
#' @importFrom geojsonio geojson_read
#' @importFrom httr parse_url
#' @importFrom mime guess_type
#' 
#' @export
read.socrataGEO <- function(url = "", ...) {
  
  parseUrl <- httr::parse_url(url)
  mimeType <- mime::guess_type(parseUrl$path)
  
  if (mimeType == "application/vnd.geo+json") {
    results <- geojsonio::geojson_read(url, method = "local", what = "list", parse = FALSE, ...)
  } 
  
  return(results)
}  

#' Get the SoDA 2 data types
#'
#' Get the Socrata Open Data Application Program Interface data types from the http response header. 
#' Used only for CSV and JSON, not GeoJSON
#' 
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
#' @param response - headers attribute from an httr response object
#' @return a named vector mapping field names to data types
#' @importFrom jsonlite fromJSON
#' @noRd
getSodaTypes <- function(response) {
  
  # check if types and fields are not null
  if (!is.null(response$headers[['x-soda2-types']]) | !is.null(response$headers[['x-soda2-fields']])) {
    
    result <- jsonlite::fromJSON(response$headers[['x-soda2-types']])
    names(result) <- jsonlite::fromJSON(response$headers[['x-soda2-fields']])
    return(result)
    
  } else {
    NULL
  }
  
}

