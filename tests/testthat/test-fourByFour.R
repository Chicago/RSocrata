library(testthat)
library(RSocrata)
library(httr)
library(jsonlite)
library(mime)

context("Checks the validity of 4x4")

test_that("is 4x4", {
  expect_true(isFourByFour("4334-bgaj"), label="ok")
  expect_false(isFourByFour("4334c-bgajc"), label="11 characters instead of 9")
  expect_false(isFourByFour("433-bga"), label="7 characters instead of 9")
  expect_false(isFourByFour("433-bgaj"), label="3 characters before dash instead of 4")
  expect_false(isFourByFour("4334-!gaj"), label="non-alphanumeric character")
})


test_that("URLs contain 4x4 format", {
  expect_error(read.socrata("https://soda.demo.socrata.com/api/views/4334c-bgajc"))
  expect_error(read.socrata("https://soda.demo.socrata.com/api/views/433-bga"))
  expect_error(read.socrata("https://soda.demo.socrata.com/api/views/433-bgaj"))
  expect_error(read.socrata("https://soda.demo.socrata.com/api/views/4334-!gaj"))
})
