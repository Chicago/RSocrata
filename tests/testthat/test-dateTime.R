library(testthat)
library(RSocrata)
library(httr)
library(jsonlite)
library(mime)

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
