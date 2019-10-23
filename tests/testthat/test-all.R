library(testthat)
library(RSocrata)
library(httr)
library(jsonlite)
library(mime)
library(plyr)

## Credentials for testing private dataset and update dataset functionality ##
# This is commented out because of issue #174 as a temporary work-around. 
# This should be re-enabled in the future with a work-around.
socrataEmail <- Sys.getenv("SOCRATA_EMAIL", "mark.silverberg+soda.demo@socrata.com")
socrataPassword <- Sys.getenv("SOCRATA_PASSWORD", "7vFDsGFDUG")

context("posixify function")

test_that("read Socrata CSV is compatible with posixify", {
  df <- read.socrata('http://soda.demo.socrata.com/resource/4334-bgaj.csv')
  dt <- posixify("09/14/2012 10:38:01 PM")
  expect_equal(dt, df$datetime[1])  ## Check that download matches test
})

test_that("read Socrata JSON is compatible with posixify (issue 85)", {
  ## Define and test issue 85
  df <- read.socrata('https://soda.demo.socrata.com/resource/9szf-fbd4.json')
  dt <- posixify("09/14/2012 10:38:01 PM")
  expect_equal(dt, df$datetime[1], info= "Testing Issue 85 https://github.com/Chicago/RSocrata/issues/85")  ## Check that download matches test
})

test_that("read Socrata JSON that uses ISO 8601 but does not specify subseconds", {
  df <- read.socrata('https://data.cityofnewyork.us/resource/qcdj-rwhu.json') # Not from #121, but smaller for shorter test process
  expect_false(anyNA(df$app_status_date), info= "Testing issue 121 https://github.com/Chicago/RSocrata/issues/121")
})

test_that("posixify returns Long format", {
  dt <- posixify("09/14/2012 10:38:01 PM")
  expect_equal("POSIXct", class(dt)[1], label="Long format date data type")
  expect_equal("2012", format(dt, "%Y"), label="year")
  expect_equal("09", format(dt, "%m"), label="month")
  expect_equal("14", format(dt, "%d"), label="day")
  expect_equal("22", format(dt, "%H"), label="hours")
  expect_equal("38", format(dt, "%M"), label="minutes")
  expect_equal("01", format(dt, "%S"), label="seconds")
})


test_that("posixify returns Short format", {
  dt <- posixify("09/14/2012")
  expect_equal("POSIXct", class(dt)[1], label="Short format date data type")
  expect_equal("2012", format(dt, "%Y"), label="year")
  expect_equal("09", format(dt, "%m"), label="month")
  expect_equal("14", format(dt, "%d"), label="day")
  expect_equal("00", format(dt, "%H"), label="hours")
  expect_equal("00", format(dt, "%M"), label="minutes")
  expect_equal("00", format(dt, "%S"), label="seconds")
})

context("Socrata Calendar")

test_that("Calendar Date Short", {
  df <- read.socrata('http://data.cityofchicago.org/resource/y93d-d9e3.csv?$order=debarment_date')
  dt <- df$debarment_date[1] # "05/21/1981"
  expect_equal("POSIXct", class(dt)[1], label="data type of a date")
  expect_equal("81", format(dt, "%y"), label="year")
  expect_equal("05", format(dt, "%m"), label="month")
  expect_equal("21", format(dt, "%d"), label="day")
  expect_equal("00", format(dt, "%H"), label="hours")
  expect_equal("00", format(dt, "%M"), label="minutes")
  expect_equal("00", format(dt, "%S"), label="seconds")
})

test_that("Date is not entirely NA if the first record is bad (issue 68)", {
  
  ## Define and test issue 68
  # df <- read.socrata('http://data.cityofchicago.org/resource/me59-5fac.csv')
  # expect_false(object = all(is.na(df$Creation.Date)),
  #              "Testing issue 68 https://github.com/Chicago/RSocrata/issues/68")
  
  df <- read.socrata("https://data.cityofchicago.org/resource/4h87-zdcp.csv")
  expect_false(object = all(is.na(df$date_received)),
               "Testing issue 68 https://github.com/Chicago/RSocrata/issues/68")
  
  
  ## Define smaller tests
  dates_clean <- posixify(c("01/01/2011", "01/01/2011", "01/01/2011"))
  dates_mixed <- posixify(c("Date", "01/01/2011", "01/01/2011"))
  
  ## Execute smaller tests
  expect_true(all(!is.na(dates_clean)))  ## Nothing should be NA
  expect_true(any(is.na(dates_mixed)))   ## Some should be NA
  expect_true(any(!is.na(dates_mixed)))  ## Some should not be NA
  expect_warning(posixify(c("Date", "junk", "junk"))) ## Should return warning
})

context("change money to numeric")

test_that("Fields with currency symbols remove the symbol and convert to money", {
  deniro <- "$15325.65"
  deniro <- no_deniro(deniro)
  expect_equal(15325.65, deniro, label="dollars")
  expect_equal("numeric", class(deniro), label="output of money fields")
})

test_that("converts money fields to numeric from Socrata", {
  df <- read.socrata("https://data.cityofchicago.org/Administration-Finance/Current-Employee-Names-Salaries-and-Position-Title/xzkq-xp2w")
  expect_equal("numeric", class(df$annual_salary), label="dollars")
  expect_equal("numeric", class(df$annual_salary), label="output of money fields")
})

context("read Socrata")

test_that("read Socrata CSV as default", {
  df <- read.socrata('https://soda.demo.socrata.com/resource/4334-bgaj.csv')
  expect_equal("data.frame", class(df), label="class")
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(9, ncol(df), label="columns")
  expect_equal(c("character", "character", "character", "POSIXct", "numeric", 
                 "numeric", "integer", "character", "character"), 
               unname(sapply(sapply(df, class),`[`, 1)), 
               label="testing column CSV classes with defaults")
})

test_that("read Socrata CSV from New Backend (NBE) endpoint", {
  df <- read.socrata("https://odn.data.socrata.com/resource/pvug-y23y.csv")
  expect_equal("data.frame", class(df), label="class", info="https://github.com/Chicago/RSocrata/issues/118")
  expect_equal(4, ncol(df), label="columns", info="https://github.com/Chicago/RSocrata/issues/118")
  expect_equal(c("character", "character", "character", "integer"), 
               unname(sapply(sapply(df, class),`[`, 1)), 
               label="testing column CSV classes with defaults")
})

test_that("Warn instead of fail if X-SODA2-* headers are missing", {
  
  ## These data sets are identified in #118 as data sets with missing soda 
  ## headers. The missing header should cause the data set to return character 
  ## columns instead of columns cast into their appropriate classes.
  ## RSocrata should also warn the user when the header is missing.
  url_csv_missing <- "https://data.healthcare.gov/resource/enx3-h2qp.csv?$limit=1000"
  url_json_missing <- "https://data.healthcare.gov/resource/enx3-h2qp.json?$limit=1000"
  ## These URLs should have soda types in the header
  url_csv_complete <- "https://odn.data.socrata.com/resource/pvug-y23y.csv"
  url_json_complete <- "https://odn.data.socrata.com/resource/pvug-y23y.json"
  
  msg <- "https://github.com/Chicago/RSocrata/issues/118"
  
  ## Check that the soda2 headers are missing
  expect_null(RSocrata:::getResponse(url_csv_missing)$headers[['x-soda2-types']], info=msg)
  expect_null(RSocrata:::getResponse(url_json_missing)$headers[['x-soda2-types']], info=msg)
  
  ## Check for warning that the header is missing, which causes the column 
  ## classes to be returned as character
  expect_warning(dfCsv <- read.socrata(url_csv_missing), info=msg)
  expect_warning(dfJson <- read.socrata(url_json_missing), info=msg)
  
  ## Check that the soda2 headers are present
  expect_false(is.null(RSocrata:::getResponse(url_csv_complete)$headers[['x-soda2-types']]), info=msg)
  expect_false(is.null(RSocrata:::getResponse(url_json_complete)$headers[['x-soda2-types']]), info=msg)
  
  ## Check that they return results without warning
  expect_silent(df <- read.socrata(url_csv_complete))
  expect_silent(df <- read.socrata(url_json_complete))
  
})

test_that("read Socrata CSV as character", {
  df <- read.socrata('https://soda.demo.socrata.com/resource/4334-bgaj.csv',
                     stringsAsFactors = FALSE)
  expect_equal("data.frame", class(df), label="class")
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(9, ncol(df), label="columns")
  expect_equal(c("character", "character", "character", "POSIXct", "numeric", 
                 "numeric", "integer", "character", "character"), 
               unname(sapply(sapply(df, class),`[`, 1)))
})

test_that("read Socrata CSV as factor", {
  df <- read.socrata('https://soda.demo.socrata.com/resource/4334-bgaj.csv',
                     stringsAsFactors = TRUE)
  expect_equal("data.frame", class(df), label="class")
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(9, ncol(df), label="columns")
  expect_equal(c("factor", "factor", "factor", "POSIXct", "numeric", 
                 "numeric", "integer", "factor", "factor"), 
               unname(sapply(sapply(df, class),`[`, 1)))
})


test_that("read Socrata JSON as default", {
  df <- read.socrata('https://soda.demo.socrata.com/resource/4334-bgaj.json')
  expect_equal("data.frame", class(df), label="class")
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(10, ncol(df), label="columns")
  expect_equal(c("character", "character", "character", "POSIXct", "character", 
                 "character", "character", "character", "character", 
                 "character"), 
               unname(sapply(sapply(df, class),`[`, 1)))
})

test_that("read Socrata JSON as character", {
  df <- read.socrata('https://soda.demo.socrata.com/resource/4334-bgaj.json',
                     stringsAsFactors = FALSE)
  expect_equal("data.frame", class(df), label="class")
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(10, ncol(df), label="columns")
  expect_equal(c("character", "character", "character", "POSIXct", "character", 
                 "character", "character", "character", "character",  
                 "character"), 
               unname(sapply(sapply(df, class),`[`, 1)))
})

test_that("read Socrata JSON as factor", {
  df <- read.socrata('https://soda.demo.socrata.com/resource/4334-bgaj.json',
                     stringsAsFactors = TRUE)
  expect_equal("data.frame", class(df), label="class")
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(10, ncol(df), label="columns")
  expect_equal(c("factor", "factor", "factor", "POSIXct", "factor", "factor", 
                 "factor", "factor", "factor", "factor"), 
               unname(sapply(sapply(df, class),`[`, 1)))
})


test_that("read Socrata No Scheme", {
  expect_error(read.socrata('soda.demo.socrata.com/resource/4334-bgaj.csv'))
})

test_that("readSoQL", {
  df <- read.socrata('http://soda.demo.socrata.com/resource/4334-bgaj.csv?$select=region')
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(1, ncol(df), label="columns")
})

test_that("URL is private (Unauthorized) (will fail)", {
  expect_error(read.socrata('http://data.cityofchicago.org/resource/j8vp-2qpg.json'))
})

test_that("readSocrataHumanReadable", {
  df <- read.socrata('https://soda.demo.socrata.com/dataset/USGS-Earthquake-Reports/4334-bgaj')
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(9, ncol(df), label="columns")
})

test_that("Read URL provided by data.json from ls.socrata() - CSV", {
  df <- read.socrata('https://soda.demo.socrata.com/api/views/4334-bgaj/rows.csv?accessType=DOWNLOAD')
  expect_equal(1007, nrow(df), label="rows", info="Testing for issue #124")
  expect_equal(9, ncol(df), label="columns")
})

test_that("Read URL provided by data.json from ls.socrata() - JSON", {
  df <- read.socrata('https://soda.demo.socrata.com/api/views/4334-bgaj/rows.json?accessType=DOWNLOAD')
  expect_equal(1007, nrow(df), label="rows", info="Testing for issue #124")
  expect_equal(9, ncol(df), label="columns")
})

# This test is commented out because of issue #137 as a temporary work-around. 
# Test should be re-enabled in the future with a work-around.
# 
# test_that("Read data with missing dates", { # See issue #24 & #27 
#   # Query below will pull Boston's 311 requests from early July 2011. Contains NA dates.
#   df <- read.socrata("https://data.cityofboston.gov/resource/awu8-dc52.csv?$where=case_enquiry_id< 101000295717")
#   expect_equal(99, nrow(df), label="rows")
#   na_time_rows <- df[is.na(df$TARGET_DT), ]
#   expect_equal(33, length(na_time_rows), label="rows with missing TARGET_DT dates")
# })

test_that("format is not supported", {
  # Unsupported data formats
  expect_error(read.socrata('http://soda.demo.socrata.com/resource/4334-bgaj.xml'))
})

test_that("read Socrata JSON with missing fields (issue 19 - bind within page)", {
  ## Define and test issue 19
  expect_error(df <- read.socrata("https://data.cityofchicago.org/resource/kn9c-c2s2.json"), NA,
               info = "https://github.com/Chicago/RSocrata/issues/19")
  expect_equal(78, nrow(df), label="rows", info = "https://github.com/Chicago/RSocrata/issues/19")
  expect_equal(9, ncol(df), label="columns", info = "https://github.com/Chicago/RSocrata/issues/19")
})

test_that("read Socrata JSON with missing fields (issue 19 - binding pages together)", {
  ## Define and test issue 19
  df <- read.socrata(paste0("https://data.smgov.net/resource/ia9m-wspt.json?",
                            "$where=incident_date>='2011-01-01'%20AND%20incident_date<'2011-01-15'"))
  expect_error(df, NA, info = "https://github.com/Chicago/RSocrata/issues/19")
  expect_equal(3719, nrow(df), label="rows", info = "https://github.com/Chicago/RSocrata/issues/19")
  expect_equal(15, ncol(df), label="columns", info = "https://github.com/Chicago/RSocrata/issues/19")
})

test_that("Accept a URL with a $limit= clause and properly limit the results", {
  ## Define and test issue 83
  df <- read.socrata("http://soda.demo.socrata.com/resource/4334-bgaj.json?$LIMIT=500") # uppercase
  expect_equal(500, nrow(df), label="rows", 
               info = "$LIMIT in uppercase https://github.com/Chicago/RSocrata/issues/83")
  df <- read.socrata("http://soda.demo.socrata.com/resource/4334-bgaj.json?$limit=500") # lowercase
  expect_equal(500, nrow(df), label="rows", 
               info = "$limit in lowercase https://github.com/Chicago/RSocrata/issues/83")
  df <- read.socrata("http://soda.demo.socrata.com/resource/4334-bgaj.json?$LIMIT=1001&$order=:id") # uppercase
  expect_equal(1001, nrow(df), label="rows", 
               info = "$LIMIT in uppercase with 2 queries https://github.com/Chicago/RSocrata/issues/83")
  df <- read.socrata("http://soda.demo.socrata.com/resource/4334-bgaj.json?$limit=1001&$order=:id") # lowercase
  expect_equal(1001, nrow(df), label="rows lowercase", 
               info = "$LIMIT in lowercase with 2 queries https://github.com/Chicago/RSocrata/issues/83")
})
  
test_that("If URL has no queries, insert $order:id into URL", {
  ## Define and test issue 15
  ## Ensure that the $order=:id is inserted when no other query parameters are used.
  df <- read.socrata("https://data.cityofchicago.org/resource/kn9c-c2s2.json")
  expect_equal("21.5", df$percent_aged_under_18_or_over_64[7], 
               info = "https://github.com/Chicago/RSocrata/issues/15")
  expect_equal("38", df$percent_aged_under_18_or_over_64[23], 
               info = "https://github.com/Chicago/RSocrata/issues/15")
  expect_equal("40.4", df$percent_aged_under_18_or_over_64[36], 
               info = "https://github.com/Chicago/RSocrata/issues/15")
  expect_equal("36.1", df$percent_aged_under_18_or_over_64[42], 
               info = "https://github.com/Chicago/RSocrata/issues/15")
  
})

test_that("If URL has an $order clause, do not insert ?$order:id into URL", {
  ## Define and test issue 15
  ## Ensure that $order=:id is not used when other $order parameters are requested by the user.
  df <- read.socrata("https://data.cityofchicago.org/resource/kn9c-c2s2.json?$order=hardship_index")
  expect_equal("35.3", df$percent_aged_under_18_or_over_64[7], 
               info = "https://github.com/Chicago/RSocrata/issues/15")
  expect_equal("37.6", df$percent_aged_under_18_or_over_64[23], 
               info = "https://github.com/Chicago/RSocrata/issues/15")
  expect_equal("38.5", df$percent_aged_under_18_or_over_64[36], 
               info = "https://github.com/Chicago/RSocrata/issues/15")
  expect_equal("32", df$percent_aged_under_18_or_over_64[42], 
               info = "https://github.com/Chicago/RSocrata/issues/15")
})

test_that("If URL has only non-order query parameters, insert $order:id into URL", {
  ## Define and test issue 15
  ## Ensure that $order=:id is inserted when other (non-$order) arguments are used.
  df <- read.socrata("https://data.cityofchicago.org/resource/kn9c-c2s2.json?$limit=50")
  expect_equal("21.5", df$percent_aged_under_18_or_over_64[7], 
               info = "https://github.com/Chicago/RSocrata/issues/15")
  expect_equal("38", df$percent_aged_under_18_or_over_64[23], 
               info = "https://github.com/Chicago/RSocrata/issues/15")
  expect_equal("40.4", df$percent_aged_under_18_or_over_64[36], 
               info = "https://github.com/Chicago/RSocrata/issues/15")
  expect_equal("36.1", df$percent_aged_under_18_or_over_64[42], 
               info = "https://github.com/Chicago/RSocrata/issues/15")
  df <- read.socrata("https://data.cityofchicago.org/resource/kn9c-c2s2.json?$where=hardship_index>20")
  expect_equal("34", df$percent_aged_under_18_or_over_64[7], 
               info = "https://github.com/Chicago/RSocrata/issues/15")
  expect_equal("30.7", df$percent_aged_under_18_or_over_64[23], 
               info = "https://github.com/Chicago/RSocrata/issues/15")
  expect_equal("41.2", df$percent_aged_under_18_or_over_64[36], 
               info = "https://github.com/Chicago/RSocrata/issues/15")
  expect_equal("42.9", df$percent_aged_under_18_or_over_64[42], 
               info = "https://github.com/Chicago/RSocrata/issues/15")  
})

test_that("Handle URL with query that does not return :id", {
  ## Define and test issue 120
  ## Ensure that the $order=:id is inserted when no other query parameters are used.
  qurl <-  "https://data.cityofchicago.org/resource/wrvz-psew.csv?$select=count(trip_id)&$where=trip_start_timestamp between '2016-04-01T00:00:00' and '2016-04-05T00:00:00'"
  dat <- read.socrata(qurl)
  expect_equal(1, ncol(dat), 
               info = "https://github.com/Chicago/RSocrata/issues/120")
})


context("Checks the validity of 4x4")

test_that("is 4x4", {
  expect_true(isFourByFour("4334-bgaj"), label="ok")
  expect_false(isFourByFour("4334c-bgajc"), label="11 characters instead of 9")
  expect_false(isFourByFour("433-bga"), label="7 characters instead of 9")
  expect_false(isFourByFour("433-bgaj"), label="3 characters before dash instead of 4")
  expect_false(isFourByFour("4334-!gaj"), label="non-alphanumeric character")
})


test_that("is 4x4 URL", {
  expect_error(read.socrata("https://soda.demo.socrata.com/api/views/4334c-bgajc"), "4334c-bgajc is not a valid Socrata dataset unique identifier", label="11 characters instead of 9")
  expect_error(read.socrata("https://soda.demo.socrata.com/api/views/433-bga"), "433-bga is not a valid Socrata dataset unique identifier", label="7 characters instead of 9")
  expect_error(read.socrata("https://soda.demo.socrata.com/api/views/433-bgaj"), "433-bgaj is not a valid Socrata dataset unique identifier", label="3 characters before dash instead of 4")
  expect_error(read.socrata("https://soda.demo.socrata.com/api/views/4334-!gaj"), "4334-!gaj is not a valid Socrata dataset unique identifier", label="non-alphanumeric character")
})

test_that("Invalid URL", {
  expect_error(read.socrata("a.fake.url.being.tested"), "a.fake.url.being.tested does not appear to be a valid URL", label="invalid url")
})

context("Test Socrata with Token")

test_that("CSV with Token", {
  df <- read.socrata('https://soda.demo.socrata.com/resource/4334-bgaj.csv', app_token="ew2rEMuESuzWPqMkyPfOSGJgE")
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(9, ncol(df), label="columns")  
})


test_that("readSocrataHumanReadableToken", {
  df <- read.socrata('https://soda.demo.socrata.com/dataset/USGS-Earthquake-Reports/4334-bgaj', app_token="ew2rEMuESuzWPqMkyPfOSGJgE")
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(9, ncol(df), label="columns")  
})

test_that("API Conflict", {
  df <- read.socrata('https://soda.demo.socrata.com/resource/4334-bgaj.csv?$$app_token=ew2rEMuESuzWPqMkyPfOSGJgE', app_token="ew2rEMuESuzWPqMkyPfOSUSER")
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(9, ncol(df), label="columns")
  # Check that function is calling the API token specified in url
  expect_true(substr(validateUrl('https://soda.demo.socrata.com/resource/4334-bgaj.csv?$$app_token=ew2rEMuESuzWPqMkyPfOSGJgE', app_token="ew2rEMuESuzWPqMkyPfOSUSER"), 70, 94)=="ew2rEMuESuzWPqMkyPfOSGJgE")
})

test_that("readAPIConflictHumanReadable", {
  df <- read.socrata('https://soda.demo.socrata.com/dataset/USGS-Earthquake-Reports/4334-bgaj?$$app_token=ew2rEMuESuzWPqMkyPfOSGJgE', app_token="ew2rEMuESuzWPqMkyPfOSUSER")
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(9, ncol(df), label="columns")
  # Check that function is calling the API token specified in url
  expect_true(substr(validateUrl('https://soda.demo.socrata.com/dataset/USGS-Earthquake-Reports/4334-bgaj?$$app_token=ew2rEMuESuzWPqMkyPfOSGJgE', app_token="ew2rEMuESuzWPqMkyPfOSUSER"), 70, 94)=="ew2rEMuESuzWPqMkyPfOSGJgE")
})

test_that("incorrect API Query", {
  # The query below is missing a $ before app_token.
  expect_error(read.socrata("https://soda.demo.socrata.com/resource/4334-bgaj.csv?$app_token=ew2rEMuESuzWPqMkyPfOSGJgE"))
  # Check that it was only because of missing $  
  df <- read.socrata("https://soda.demo.socrata.com/resource/4334-bgaj.csv?$$app_token=ew2rEMuESuzWPqMkyPfOSGJgE")
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(9, ncol(df), label="columns") 
})

test_that("Ensure filtering and app tokens can coexist - API", {
  # Test includes filter and app_token as an R optional argument
  df <- read.socrata("https://soda.demo.socrata.com/resource/4334-bgaj.csv?$where=magnitude > 3.0", app_token="ew2rEMuESuzWPqMkyPfOSGJgE")
  expect_equal(193, nrow(df), label = "rows", info = "https://github.com/Chicago/RSocrata/issues/105")
})

test_that("incorrect API Query Human Readable", {
  # The query below is missing a $ before app_token.
  expect_error(read.socrata("https://soda.demo.socrata.com/dataset/USGS-Earthquake-Reports/4334-bgaj?$app_token=ew2rEMuESuzWPqMkyPfOSGJgE"))
  # Check that it was only because of missing $  
  df <- read.socrata("https://soda.demo.socrata.com/dataset/USGS-Earthquake-Reports/4334-bgaj?$$app_token=ew2rEMuESuzWPqMkyPfOSGJgE")
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(9, ncol(df), label="columns") 
})

context("URL suffixes from Socrata are handled")

test_that("Handle /data suffix", {
  df1 <- read.socrata('https://soda.demo.socrata.com/dataset/USGS-Earthquake-Reports/4334-bgaj/data')
  expect_equal(1007, nrow(df1), label="rows")
  expect_equal(9, ncol(df1), label="columns")
  df2 <- read.socrata('https://soda.demo.socrata.com/dataset/USGS-Earthquake-Reports/4334-bgaj/data/')
  expect_equal(1007, nrow(df2), label="rows")
  expect_equal(9, ncol(df2), label="columns")
})

context("ls.socrata functions correctly")

test_that("List datasets available from a Socrata domain", {
  # Makes some potentially erroneous assumptions about availability
  # of soda.demo.socrata.com
  df <- ls.socrata("https://soda.demo.socrata.com")
  expect_equal(TRUE, nrow(df) > 0)
  # Test comparing columns against data.json specifications:
  # https://project-open-data.cio.gov/v1.1/schema/
  core_names <- as.character(c("issued", "modified", "keyword", "@type", "landingPage", "theme", 
                               "title", "accessLevel", "distribution", "description", 
                               "identifier", "publisher", "contactPoint", "license"))
  expect_equal(as.logical(rep(TRUE, length(core_names))), core_names %in% names(df))
  # Check that all names in data.json are accounted for in ls.socrata return
  expect_equal(as.logical(rep(TRUE, length(names(df)))), names(df) %in% c(core_names))
})

test_that("Catalog Fields are assigned as attributes when listing data sets", {
  df <- ls.socrata("https://soda.demo.socrata.com")
  catalog_fields <- c("@context", "@id", "@type", "conformsTo", "describedBy")
  expect_equal(as.logical(rep(TRUE, length(catalog_fields))), catalog_fields %in% names(attributes(df)))
})

context("Test reading private Socrata dataset with email and password")

privateResourceToReadCsvUrl <- "https://soda.demo.socrata.com/resource/a9g2-feh2.csv"
privateResourceToReadJsonUrl <- "https://soda.demo.socrata.com/resource/a9g2-feh2.json"

test_that("read Socrata CSV that requires a login", {
  skip('See Issue #174')
  # should error when no email and password are sent with the request
  expect_error(read.socrata(url = privateResourceToReadCsvUrl))
  # try again, this time with email and password in the request
  df <- read.socrata(url = privateResourceToReadCsvUrl, email = socrataEmail, password = socrataPassword)
  # tests
  expect_equal(2, ncol(df), label="columns")
  expect_equal(3, nrow(df), label="rows")
})

test_that("read Socrata JSON that requires a login", {
  skip('See Issue #174')
  # should error when no email and password are sent with the request
  expect_error(read.socrata(url = privateResourceToReadJsonUrl))
  # try again, this time with email and password in the request
  df <- read.socrata(url = privateResourceToReadJsonUrl, email = socrataEmail, password = socrataPassword)
  # tests
  expect_equal(2, ncol(df), label="columns")
  expect_equal(3, nrow(df), label="rows")
})

context("write Socrata datasets")

test_that("add a row to a dataset", {
  skip('See Issue #174')
  datasetToAddToUrl <- "https://soda.demo.socrata.com/resource/xh6g-yugi.json"

  # populate df_in with two columns, each with a random number
  x <- sample(-1000:1000, 1)
  y <- sample(-1000:1000, 1)
  df_in <- data.frame(x,y)

  # write to dataset
  res <- write.socrata(df_in,datasetToAddToUrl,"UPSERT",socrataEmail,socrataPassword)
  
  # Check that the dataset was written without error
  expect_equal(res$status_code, 200L)

})


test_that("fully replace a dataset", {
  skip('See Issue #174')
  datasetToReplaceUrl <- "https://soda.demo.socrata.com/resource/kc76-ybeq.json"

  # populate df_in with two columns of random numbers
  x <- sample(-1000:1000, 5)
  y <- sample(-1000:1000, 5)
  df_in <- data.frame(x,y)

  # write to dataset
  res <- write.socrata(df_in,datasetToReplaceUrl,"REPLACE",socrataEmail,socrataPassword)

  # Check that the dataset was written without error
  expect_equal(res$status_code, 200L)
})


context("getContentAsDataFrame")

test_that("getContentAsDataFrame does not get caught in infinite loop", {
  
  ## This is the original url suggested, but it causes the rbind issue
  # u <- paste0("https://data.smgov.net/resource/xx64-wi4x.json?$",
  #             "select=incident_number,incident_date,call_type,received_time,",
  #             "cleared_time,census_tract_2010_geoid",
  #             "&$where=incident_date=%272016-08-21%27")
  
  ## This request has been modified to avoid the rbind issue
  u <- paste0("https://data.smgov.net/resource/xx64-wi4x.json?$",
              "select=incident_number,incident_date,call_type,received_time,",
              "cleared_time,census_tract_2010_geoid",
              "&$where=incident_date=%272016-08-27%27%20and%20",
              "census_tract_2010_geoid%20is%20not%20null")
  df <- read.socrata(u)
  expect_equal("data.frame", class(df), label="class")
})

