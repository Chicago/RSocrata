#' Convert Socrata human-readable column name to field name
#' 
#' @description Convert Socrata human-readable column name,
#' as it might appear in the first row of data,
#' to field name as it might appear in the HTTP header;
#' that is, lower case, periods replaced with underscores
#' 
#' @param humanName - a Socrata human-readable column name
#' @return Socrata field name in lower case
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
#' @examples
#' fieldName("Number.of.Stations") # number_of_stations
#' 
#' @export
fieldName <- function(humanName = "") {
  tolower(gsub('\\.', '_', humanName))
}

#' Convert Socrata calendar_date string to POSIX
#' 
#' @description Datasets will either specify what timezone they should be interpreted in, 
#' or you can usually assume they are in the timezone of the publisher. See examples below too. 
#' 
#' @seealso \url{http://dev.socrata.com/docs/datatypes/floating_timestamp.html}
#' @param x - character vector in one of two Socrata calendar_date formats
#' @return a POSIX date
#' @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
#' @examples 
#' posixify("2014-10-13T23:00:00")
#' posixify("09/14/2012 10:38:01 PM")
#' posixify("09/14/2012")
#' 
#' @export
posixify <- function(x = "") {
  
  # https://github.com/Chicago/RSocrata/issues/24
  if (length(x) == 0) {
    return(x)
  }
  
  # Three calendar date formats supplied by Socrata
  # https://github.com/GregDThomas/jquery-localtime/issues/1
  
  if (regexpr("^(-?(?:[1-9][0-9]*)?[0-9]{4})-(1[0-2]|0[1-9])-(3[0-1]|0[1-9]|[1-2][0-9])T(2[0-3]|[0-1][0-9]):([0-5][0-9]):([0-5][0-9])(.[0-9]+)?(Z|[+-](?:2[0-3]|[0-1][0-9]):[0-5][0-9])?$", x) == TRUE) { 
    # floating timestamp
    strptime(x, format = "%Y-%m-%dT%H:%M:%S") 
    
  } else if (any(regexpr("^[[:digit:]]{1,2}/[[:digit:]]{1,2}/[[:digit:]]{4}$", x[1])[1] == TRUE)) {
    # short date format
    strptime(x, format="%m/%d/%Y") 
    
  } else {
    # long date-time format
    strptime(x, format="%m/%d/%Y %I:%M:%S %p") 
    
  }
  
}