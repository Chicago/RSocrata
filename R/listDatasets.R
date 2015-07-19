#' List datasets available from a Socrata domain
#'
#' @param url - A Socrata URL. This simply points to the site root. 
#' @return an R data frame containing a listing of datasets along with
#' various metadata.
#' @author Peter Schmiedeskamp \email{pschmied@@uw.edu}
#' @note URLs such as \code{"soda.demo.socrata.com"} are not supported
#' @examples
#' df <- ls.socrata(url = "http://soda.demo.socrata.com")
#' ## df.ny <- ls.socrata("https://data.ny.gov/")
#' 
#' @importFrom jsonlite fromJSON
#' @importFrom httr parse_url build_url
#' 
#' @export
ls.socrata <- function(url = "") {
  
  parsedUrl <- httr::parse_url(url)
  
  if(is.null(parsedUrl$scheme) | is.null(parsedUrl$hostname)) {
    stop(url, " does not appear to be a valid URL.")
  }
  parsedUrl$path <- "data.json"
  
  df <- jsonlite::fromJSON(httr::build_url(parsedUrl))
  df <- as.data.frame(df$dataset, stringsAsFactors = FALSE)
  df$issued <- as.POSIXct(df$issued)
  df$modified <- as.POSIXct(df$modified)
  df$theme <- as.character(df$theme)
  
  return(df)
}