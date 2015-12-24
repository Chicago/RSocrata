#' Checks the validity of the syntax for a potential Socrata dataset Unique Identifier, also known as a 4x4.
#'
#' @description Will check the validity of a potential dataset unique identifier
#' supported by Socrata. It will provide an exception if the syntax
#' does not align to Socrata unique identifiers. It only checks for
#' the validity of the syntax, but does not check if it actually exists.
#' 
#' @param fourByFour - a string; character vector of length one
#' @return TRUE if is valid Socrata unique identifier, FALSE otherwise
#' @author Tom Schenk Jr \email{tom.schenk@@cityofchicago.org} et al.
#' @examples 
#' isFourByFour(fourByFour = "4334-bgaj")
#' isFourByFour("433-bgaj")
#' isFourByFour(fourByFour = "4334-!gaj")
#' @export
isFourByFour <- function(fourByFour = "") {
  
  if (nchar(fourByFour) == 9) {
    if (identical(grepl("[[:alnum:]]{4}-[[:alnum:]]{4}", fourByFour), TRUE)) {
      return(TRUE)
    } else {
      return(FALSE)
    }
  } else {
    return(FALSE)
  }
  
}

# Convert Socrata human-readable column name to field name
# 
# @description Convert Socrata human-readable column name,
# as it might appear in the first row of data,
# to field name as it might appear in the HTTP header;
# that is, lower case, periods replaced with underscores
# 
# @param humanName - a Socrata human-readable column name
# @return Socrata field name in lower case
# @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org}
# @examples
# fieldName("Number.of.Stations") # number_of_stations
# @noRd
# @export
fieldName <- function(humanName = "") {
  tolower(gsub('\\.', '_', humanName))
}

# Convert Socrata calendar_date string to POSIX
# 
# @description Datasets will either specify what timezone they should be interpreted in, 
# or you can usually assume they are in the timezone of the publisher. See examples below too. 
# 
# @seealso \url{http://dev.socrata.com/docs/datatypes/floating_timestamp.html}
# @param x - character vector in one of possible Socrata calendar_date formats
# @return a POSIX date
# @author Hugh J. Devlin, Ph. D. \email{Hugh.Devlin@@cityofchicago.org} et al.
# @examples 
# posixify("2014-10-13T23:00:00")
# posixify("09/14/2012 10:38:01 PM")
# posixify("09/14/2012")
# @noRd 
# @export
posixify <- function(x = "") {
  
  # https://github.com/Chicago/RSocrata/issues/24
  # If a query with a date column returns no data (e.g. NA), posixify would fail without this
  if (length(x) == 0) {
    return(x)
  }
  
  # Three calendar date formats supplied by Socrata
  # See https://github.com/GregDThomas/jquery-localtime/issues/1 for the floating timestamp regex
  
  if (any(regexpr("^(-?(?:[1-9][0-9]*)?[0-9]{4})-(1[0-2]|0[1-9])-(3[0-1]|0[1-9]|[1-2][0-9])T(2[0-3]|[0-1][0-9]):([0-5][0-9]):([0-5][0-9])(.[0-9]+)?(Z|[+-](?:2[0-3]|[0-1][0-9]):[0-5][0-9])?$", x)[1] == TRUE)) { 
    # floating timestamp
    strptime(x, format = "%Y-%m-%dT%H:%M:%S") 
    
  } else if (any(regexpr("^[[:digit:]]{1,2}/[[:digit:]]{1,2}/[[:digit:]]{4}$", x)[1] == TRUE)) {
    # short date format
    strptime(x, format = "%m/%d/%Y") 
    
  } else {
    # long date-time format
    strptime(x, format = "%m/%d/%Y %I:%M:%S %p") 
    
  }
  
}

# Clean everything after "?", "&" or "."
# 
# @source https://stackoverflow.com/questions/5631384/remove-everything-after-a-certain-character
# @source http://rfunction.com/archives/1499
# 
# @examples
# cleanQuest(url = "http://data.cityofchicago.org/resource/y93d-d9e3.csv?%24order=debarment_date&%24limit=50000")
# @returns http://data.cityofchicago.org/resource/y93d-d9e3.csv
# @author John Malc \email{cincenko@@outlook.com}
# @export
cleanQuest <- function(url = "") {
  cleanURL <- strsplit(url, "?",  fixed = TRUE)
  return(cleanURL[[1]][1])
}

# @export
cleanAmp <- function(url = "") {
  cleanURL <- strsplit(url, "&",  fixed = TRUE)
  return(cleanURL[[1]][1])
}

# @export
cleanDot <- function(url = "") {
  cleanURL <- strsplit(url, ".",  fixed = TRUE)
  return(cleanURL[[1]][1])
}
