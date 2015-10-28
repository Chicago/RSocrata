#' Return metadata about a Socrata dataset
#' 
#' This function returns metadata about a dataset. Generally, such metadata can be accessed
#' with browser at \code{http://DOMAIN/api/views/FOUR-FOUR/rows.json} or
#' \code{http://DOMAIN/api/views/FOUR-FOUR/columns.json}, which is used here. 
#' 
#' @param url - A Socrata resource URL, or a Socrata "human-friendly" URL!
#' 
#' @source \url{http://stackoverflow.com/a/29782941}
#'
#' @examples
#' \dontrun{
#' gM1 <- getMetadata(url = "http://data.cityofchicago.org/resource/y93d-d9e3.json")
#' gM3 <- getMetadata(url = "https://data.cityofchicago.org/resource/6zsd-86xi.json")
#' gM2 <- getMetadata(url = "https://data.cityofboston.gov/resource/awu8-dc52")
#' }
#' 
#' @return a list (!) containing a number of rows & columns and a data frame of metadata
#'
#' @importFrom jsonlite fromJSON
#' @importFrom httr parse_url build_url
#' @importFrom mime guess_type
#'
#' @author John Malc \email{cincenko@@outlook.com} 
#'  
#' @export
getMetadata <- function(url = "") {
  
  urlParsedBase <- httr::parse_url(url)
  mimeType <- mime::guess_type(urlParsedBase$path)
  
  # use function below to get them using =COUNT(*) SODA query
  gQRC <- getQueryRowCount(urlParsedBase, mimeType) 
  
  # create URL for metadata data frame
  fourByFour <- substr(basename(urlParsedBase$path), 1, 9)
  urlParsed <- urlParsedBase
  urlParsed$path <- paste0("api/views/", fourByFour, "/columns.json")
  
  # execute it
  URL <- httr::build_url(urlParsed)
  df <- jsonlite::fromJSON(URL)
  
  # number of rows can be sometimes "cached". If yes, then below we calculate the maximum number of 
  # rows from all non-null and null fields. 
  # If not, then it uses "getQueryRowCount" fnct with SODA =COUNT(*) SODA query.
  rows <- if (suppressWarnings(max(df$cachedContents$non_null + df$cachedContents$null)) > 0) {
    suppressWarnings(max(df$cachedContents$non_null + df$cachedContents$null))
  } else {
    # as.numeric(ifelse(is.null(gQRC$count), gQRC$COUNT, gQRC$count)) # the reason
    as.numeric(tolower(gQRC$COUNT))
  }
  
  columns <- as.numeric(nrow(df))
  
  return(list(rows = rows, cols = columns, df))
}

# Return (always & only) number of rows as specified in the metadata of the data set
#
# @source Taken from \link{https://github.com/Chicago/RSocrata/blob/sprint7/R/getQueryRowCount.R}
# @author Gene Leynes \email{gleynes@@gmail.com}
#
#' @importFrom httr GET build_url content
getQueryRowCount <- function(urlParsed, mimeType) {
  ## Construct the count query based on the URL,
  if (is.null(urlParsed[['query']])) {
    ## If there is no query at all, create a simple count
    
    cntQueryText <- "?$SELECT=COUNT(*)"
  } else {
    ## Otherwise, construct the query text with a COUNT command at the beginning of any other 
    ## limiting commands. Reconstitute the httr url into a string
    cntQueryText <- httr::build_url(structure(list(query = urlParsed[['query']]), class = "url"))
    ## Add the COUNT command to the beginning of the query
    cntQueryText <- gsub(pattern = ".+\\?", replacement = "?$SELECT=COUNT(*)&", cntQueryText)
  }
  
  ## Combine the count query with the rest of the URL
  cntUrl <- paste0(urlParsed[[c('scheme')]], "://", urlParsed[[c('hostname')]], "/",
                   urlParsed[[c('path')]], cntQueryText)
  
  ## Execute the query to count the rows
  totalRowsResult <- errorHandling(cntUrl, app_token = NULL)
  
  ## Parsing the result depends on the mime type
  if (mimeType == "application/json") {
    totalRows <- httr::content(totalRowsResult)[[1]]
  } else {
    totalRows <- httr::content(totalRowsResult)
  }
  
  ## Limit the row count to $limit (if the $limit existed). 
  # totalRows <- min(totalRows, as.numeric(rowLimit))
  
  return(totalRows)
}