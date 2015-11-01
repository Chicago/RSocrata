#' Methods required for uploading data to Socrata

#' Wrap httr GET in some diagnostics
#' 
#' In case of failure, report error details from Socrata.
#' 
#' @param url - Socrata Open Data Application Program Interface (SODA) endpoint (JSON only for now)
#' @param json_data_to_upload - JSON encoded data to update your SODA endpoint with
#' @param http_verb - PUT or POST depending on update mode
#' @param email - email associated with Socrata account (will need write access to dataset)
#' @param password - password associated with Socrata account (will need write access to dataset)
#' @param app_token - optional app_token associated with Socrata account
#' @return httr a response object
#' @importFrom httr GET
#' 
#' @noRd
checkUpdateResponse <- function(json_data_to_upload, url, http_verb, email, password, app_token = NULL) {
  if(http_verb == "POST"){
    response <- httr::POST(url,
      body = json_data_to_upload,
      httr::authenticate(email, password),
      httr::add_headers("X-App-Token" = app_token,
                  "Content-Type" = "application/json")) #, verbose())
  } else if(http_verb == "PUT"){
    response <- httr::PUT(url,
      body = json_data_to_upload,
      httr::authenticate(email, password),
      httr::add_headers("X-App-Token" = app_token,
                  "Content-Type" = "application/json")) # , verbose())
  }
  
  # TODO: error handling
  # errorHandling(response)
  
  return(response)
}

#' Write to a Socrata dataset (full replace or upsert)
#'
#' @description Method for updating Socrata datasets 
#'
#' @param dataframe - dataframe to upload to Socrata
#' @param dataset_json_endpoint - Socrata Open Data Application Program Interface (SODA) endpoint (JSON only for now)
#' @param update_mode - "UPSERT" or "REPLACE"; consult http://dev.socrata.com/publishers/getting-started.html 
#' @param email - The email to the Socrata account with read access to the dataset
#' @param password - The password associated with the email to the Socrata account
#' @param app_token - a (non-required) string; SODA API token can be used to query the data 
#' portal \url{http://dev.socrata.com/consumers/getting-started.html}
#' 
#' @author Mark Silverberg \email{mark.silverberg@@socrata.com}
#' 
#' @importFrom httr parse_url build_url
#' @importFrom plyr rbind.fill
#' 
#' @export
write.socrata <- function(dataframe, dataset_json_endpoint, update_mode, email, password, app_token = NULL) {
  
  # translate update_mode to http_verbs
  if(update_mode == "UPSERT"){
    http_verb <- "POST"
  } else if(update_mode == "REPLACE") {
    http_verb <- "PUT"
  } else {
    stop("update_mode must be UPSERT or REPLACE")
  }

  # convert dataframe to JSON
  dataframe_as_json_string <- jsonlite::toJSON(dataframe)

  # do the actual upload
  response <- checkUpdateResponse(dataframe_as_json_string, dataset_json_endpoint, http_verb, email, password, app_token)
  
  return(response)

}
