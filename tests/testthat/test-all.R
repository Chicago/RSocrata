library(testthat)
library(RSocrata)
library(httr)
library(jsonlite)
library(mime)

context("posixify function")

test_that("posixify returns Long format", {
  dt <- posixify("09/14/2012 10:38:01 PM")
  expect_equal("POSIXlt", class(dt)[1], label="first data type of a date")
  expect_equal(2012, dt$year + 1900, label="year")
  expect_equal(9, dt$mon + 1, label="month")
  expect_equal(14, dt$mday, label="day")
  expect_equal(22, dt$hour, label="hours")
  expect_equal(38, dt$min, label="minutes")
  expect_equal(1, dt$sec, label="seconds")
})


test_that("posixify returns Short format", {
  dt <- posixify("09/14/2012")
  expect_equal("POSIXlt", class(dt)[1], label="first data type of a date")
  expect_equal(2012, dt$year + 1900, label="year")
  expect_equal(9, dt$mon + 1, label="month")
  expect_equal(14, dt$mday, label="day")
  expect_equal(0, dt$hour, label="hours")
  expect_equal(0, dt$min, label="minutes")
  expect_equal(0, dt$sec, label="seconds")
})

context("read Socrata")

test_that("read Socrata CSV", {
  df <- read.socrata('https://soda.demo.socrata.com/resource/4334-bgaj.csv')
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(9, ncol(df), label="columns")
})

test_that("read Socrata JSON", {
  df <- read.socrata('https://soda.demo.socrata.com/resource/4334-bgaj.json')
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(11, ncol(df), label="columns")
})

test_that("read Socrata No Scheme", {
  expect_error(read.socrata('soda.demo.socrata.com/resource/4334-bgaj.csv'))
})

test_that("readSoQL", {
  df <- read.socrata('http://soda.demo.socrata.com/resource/4334-bgaj.csv?$select=region')
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(1, ncol(df), label="columns")
})

test_that("readSoQLColumnNotFound (will fail)", {
  # SoQL API uses field names, not human names
  expect_error(read.socrata('http://soda.demo.socrata.com/resource/4334-bgaj.csv?$select=Region'))
})

test_that("URL is private (Unauthorized) (will fail)", {
  expect_error(read.socrata('http://data.cityofchicago.org/resource/j8vp-2qpg.json'))
})

test_that("readSocrataHumanReadable", {
  df <- read.socrata('https://soda.demo.socrata.com/dataset/USGS-Earthquake-Reports/4334-bgaj')
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(9, ncol(df), label="columns")
})

test_that("format is not supported", {
  # Unsupported data formats
  expect_error(read.socrata('http://soda.demo.socrata.com/resource/4334-bgaj.xml'))
})

context("Socrata Calendar")

test_that("Calendar Date Long", {
  df <- read.socrata('http://soda.demo.socrata.com/resource/4334-bgaj.csv')
  dt <- df$Datetime[1] # "2012-09-14 22:38:01"
  expect_equal("POSIXlt", class(dt)[1], label="data type of a date")
  expect_equal(2012, dt$year + 1900, label="year")
  expect_equal(9, dt$mon + 1, label="month")
  expect_equal(14, dt$mday, label="day")
  expect_equal(22, dt$hour, label="hours")
  expect_equal(38, dt$min, label="minutes")
  expect_equal(1, dt$sec, label="seconds")
})

test_that("Calendar Date Short", {
  df <- read.socrata('http://data.cityofchicago.org/resource/y93d-d9e3.csv?$order=debarment_date')
  dt <- df$DEBARMENT.DATE[1] # "05/21/1981"
  expect_equal("POSIXlt", class(dt)[1], label="data type of a date")
  expect_equal(81, dt$year, label="year")
  expect_equal(5, dt$mon + 1, label="month")
  expect_equal(21, dt$mday, label="day")
  expect_equal(0, dt$hour, label="hours")
  expect_equal(0, dt$min, label="minutes")
  expect_equal(0, dt$sec, label="seconds")
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


test_that("incorrect API Query Human Readable", {
  # The query below is missing a $ before app_token.
  expect_error(read.socrata("https://soda.demo.socrata.com/dataset/USGS-Earthquake-Reports/4334-bgaj?$app_token=ew2rEMuESuzWPqMkyPfOSGJgE"))
  # Check that it was only because of missing $  
  df <- read.socrata("https://soda.demo.socrata.com/dataset/USGS-Earthquake-Reports/4334-bgaj?$$app_token=ew2rEMuESuzWPqMkyPfOSGJgE")
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(9, ncol(df), label="columns") 
})

test_that("List datasets available from a Socrata domain", {
  # Makes some potentially erroneous assumptions about availability
  # of soda.demo.socrata.com
  df <- ls.socrata("https://soda.demo.socrata.com")
  expect_equal(TRUE, nrow(df) > 0)
  # Test comparing columns against data.json specifications:
  # https://project-open-data.cio.gov/v1.1/schema/
  core_names <- as.character(c("issued", "modified", "keyword", "landingPage", "theme", 
                               "title", "accessLevel", "distribution", "description", 
                               "identifier", "publisher", "contactPoint", "license"))
  expect_equal(as.logical(rep(TRUE, length(core_names))), core_names %in% names(df))
  # Check that all names in data.json are accounted for in ls.socrata return
  expect_equal(as.logical(rep(TRUE, length(names(df)))), names(df) %in% c(core_names))
})









