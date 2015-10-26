#' Check if the URL is a valid one and supported by RSocrata (!).
#'
#' @description Will convert a human-readable URL to a valid REST API call
#' supported by Socrata. It will accept a valid API URL if provided
#' by users and will also convert a human-readable URL to a valid API
#' URL. Will accept queries with optional API token as a separate
#' argument or will also accept API token in the URL query. Will
#' resolve conflicting API token by deferring to original URL.
#'
#' @param url - a string; character vector of length one
#' 
#' @return a valid URL used for downloading data
#' 
#' @author Tom Schenk Jr \email{tom.schenk@@cityofchicago.org} et al.
#' 
#' @examples
#' \dontrun{
#' validateUrl(url = "a.fake.url.being.tested")
#' validateUrl(url = "https://soda.demo.socrata.com/resource/4334-bgaj")
#' validateUrl(url = "https://soda.demo.socrata.com/resource/4334-bgaj.json")
#' validateUrl(url = "https://soda.demo.socrata.com/resource/4334-bgaj.csv")
#' validateUrl(url = "http://soda.demo.socrata.com/resource/4334-bgaj.json")
#' validateUrl(url = "http://soda.demo.socrata.com/resource/4334-bgaj.xml")
#' validateUrl(url = "https://data.cityofchicago.org/resource/6zsd-86xi.geojson")
#' validateUrl(url = "http://soda.demo.socrata.com/dataset/USGS-Earthquake-Reports/4334-bgaj.csv")
#' }
#'
#' @importFrom httr parse_url build_url
#' @importFrom mime guess_type
#' 
#' @export
validateUrl <- function(url = "") {
  parsedUrl <- httr::parse_url(url)
  
  if ( is.null(parsedUrl$scheme) | is.null(parsedUrl$hostname) | is.null(parsedUrl$path)) {
    stop(url, " does not appear to be a valid URL.")
  }
  
  fourByFour <- basename(parsedUrl$path)
  if (!isFourByFour(cleanDot(fourByFour))) {
    stop(fourByFour, " is not a valid Socrata dataset unique identifier.")
  }
  
  if ( parsedUrl$scheme == "http") {
    parsedUrl$scheme <- "https"
  }
  
  # First, if suffix is CSV/XML, delete it and replace with JSON. 
  # Later, check if URL doesn't have JSON, i.e. has empty suffix, and if it does append JSON. 
  mimeType <- mime::guess_type(parsedUrl$path)
  
  if ( mimeType %in% c("text/csv", "application/xml")) {
    parsedUrl$path <- substr(parsedUrl$path, 1, nchar(parsedUrl$path) - 4) # delete
    parsedUrl$path <- paste0(parsedUrl$path, ".json") # add
    message("BEWARE: Your suffix is no longer supported. Thus, we will automatically replace it with JSON.")
    
  } else if ( mimeType == "application/json") {
    # do nothing
  } else if ( mimeType == "application/vnd.geo+json") {
    message("For GeoJSON, you must use a new method: read.socrataGEO")
    
  } else if ( mimeType == "text/plain") {
    parsedUrl$path <- paste0(parsedUrl$path, ".json") 
    
  } else {
    stop(mimeType, " has never been supported. Use JSON instead. For GeoJSON use a new method: read.socrataGEO")
  }
  
  if ( substr(parsedUrl$path, 1, 9) == "resource/") {
    return(httr::build_url(parsedUrl)) # resource url already
  } else {
    parsedUrl$path <- paste0("resource/", cleanDot(fourByFour), ".json")
    return(httr::build_url(parsedUrl)) # resource url already
  } 
  
}


