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
  expect_error(read.socrata("https://soda.demo.socrata.com/api/views/4334c-bgajc"), "4334c-bgajc is not a valid Socrata dataset unique identifier", label="11 characters instead of 9")
  expect_error(read.socrata("https://soda.demo.socrata.com/api/views/433-bga"), "433-bga is not a valid Socrata dataset unique identifier", label="7 characters instead of 9")
  expect_error(read.socrata("https://soda.demo.socrata.com/api/views/433-bgaj"), "433-bgaj is not a valid Socrata dataset unique identifier", label="3 characters before dash instead of 4")
  expect_error(read.socrata("https://soda.demo.socrata.com/api/views/4334-!gaj"), "4334-!gaj is not a valid Socrata dataset unique identifier", label="non-alphanumeric character")
})
