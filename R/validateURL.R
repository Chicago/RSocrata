#' Convert, if necessary, URL to valid REST API URL supported by Socrata.
#'
#' @description Will convert a human-readable URL to a valid REST API call
#' supported by Socrata. It will accept a valid API URL if provided
#' by users and will also convert a human-readable URL to a valid API
#' URL. Will accept queries with optional API token as a separate
#' argument or will also accept API token in the URL query. Will
#' resolve conflicting API token by deferring to original URL.
#' 
#' @param url - a string; character vector of length one
#' @param app_token - a string; SODA API token used to query the data 
#' portal \url{http://dev.socrata.com/consumers/getting-started.html}
#' @return a - valid Url
#' @importFrom httr parse_url build_url
#' @author Tom Schenk Jr \email{tom.schenk@@cityofchicago.org}
#' @examples 
#' \dontrun{
#' validateUrl(url = "a.fake.url.being.tested", app_token = "ew2rEMuESuzWPqMkyPfOSGJgE")
#' }
#' validateUrl(url = "https://soda.demo.socrata.com/dataset/USGS-Earthquake-Reports/4334-bgaj", 
#' app_token="ew2rEMuESuzWPqMkyPfOSGJgE")
#' 
#' @export
validateUrl <- function(url = "", app_token = NULL) {
  parsedUrl <- httr::parse_url(url)
  
  if(is.null(parsedUrl$scheme) | is.null(parsedUrl$hostname) | is.null(parsedUrl$path)) {
    stop(url, " does not appear to be a valid URL.")
  }
  
  if(!is.null(app_token)) { # Handles the addition of API token and resolves invalid uses
    
    if(is.null(parsedUrl$query["$$app_token"])) {
      token_inclusion <- "valid_use"
    } else {
      token_inclusion <- "already_included" 
    }
    
    switch(token_inclusion,
           "already_included" = { # Token already included in url argument
             warning(url, " already contains an API token in url. Ignoring user-defined token.")
           },
           "valid_use" = { # app_token argument is used, not duplicative.
             parsedUrl$query[["app_token"]] <- paste0("%24%24app_token=", app_token)
           }
    )
    
  } 
  
  if(substr(parsedUrl$path, 1, 9) == 'resource/') {
    return(httr::build_url(parsedUrl)) # resource url already
  }
  
  fourByFour <- basename(parsedUrl$path)
  if(!isFourByFour(fourByFour)) {
    stop(fourByFour, " is not a valid Socrata dataset unique identifier.")
  } else {
    parsedUrl$path <- paste0('resource/', fourByFour, '.csv')
    httr::build_url(parsedUrl) 
  }
  
}