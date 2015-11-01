# Provides error handling functionality
#
# @description Based on \url{http://dev.socrata.com/docs/response-codes.html}
#
# @section TODO: Add messages that alert the user on the URL being valid,
# but one that is not compatible with RSocrata.
# See \url{https://github.com/Chicago/RSocrata/issues/16}
#
# @param url - SODA url
# @param optional email - The email to the Socrata account with read access to the dataset
# @param optional password - The password associated with the email to the Socrata account
#' @importFrom httr stop_for_status GET add_headers
errorHandling <- function(url = "", app_token = NULL, email = NULL, password = NULL) {

  if(is.null(email) && is.null(password)){
    rsp <- httr::GET(url, httr::add_headers("X-App-Token" = app_token))
  } else { # email and password are not NULL
    rsp <- httr::GET(url, httr::add_headers("X-App-Token" = app_token), httr::authenticate(email, password))
  } 

  if (rsp$status_code == 200) {
    invisible("OK. Your request was successful.")
    
  } else if (rsp$status_code == 202) {
    warning("202 Request processing. You can retry your request, and when it's complete, you'll get a 200 instead.")
    
  } else if (rsp$status_code == 400) {
    stop("400 Bad request. Most probably was your request malformed (e.g URL with ?)")
    
  } else if (rsp$status_code == 401) {
    # only necessary when accessing datasets that have been marked as private or when making write requests (PUT, POST, and DELETE)
    stop("Unauthorized. You attempted to authenticate but something went wrong.")
    
  } else if (rsp$status_code == 403) {
    stop("Forbidden. You're not authorized to access this resource. Make sure you authenticate to access private datasets.")
    
  } else if (rsp$status_code == 404) {
    stop("Not found. The resource requested doesn't exist.")
    
  } else if (rsp$status_code == 429) {
    stop("Too Many Requests. Your client is currently being rate limited. Make sure you're using an app token.")
    
  } else if (rsp$status_code == 500) {
    stop("Server error. Try later.")
    
  } else {
    httr::stop_for_status(rsp)
  }
  
  return(rsp)
  
}