library(testthat)
library(RSocrata)
library(httr)
library(jsonlite)
library(mime)
library(dplyr)

# http://www.noamross.net/blog/2014/2/10/using-times-and-dates-in-r---presentation-code.html

context("Test posixify function")

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

test_that("posixify new Floating Timestamp format", {
  dt <- posixify("2014-10-13T23:25:47")
  expect_equal("POSIXlt", class(dt)[1], label="first data type of a date")
  expect_equal(2014, dt$year + 1900, label="year")
  expect_equal(25, dt$min, label="minutes")
  expect_equal(47, dt$sec, label="seconds")
})

# TODO
test_that("NA datetime in source", {
  # https://github.com/Chicago/RSocrata/issues/24
  # https://github.com/Chicago/RSocrata/issues/27
  skip_on_cran()
  skip_on_travis()
  skip_if_not_installed()
  df <- read.socrata("https://data.cityofboston.gov/resource/awu8-dc52.csv?$limit=3")
  
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



