library(testthat)
library(RSocrata)
library(httr)
library(jsonlite)
library(mime)

context("Validate URL")

test_that("Invalid URL", {
  expect_error(read.socrata("a.fake.url.being.tested"), "a.fake.url.being.tested does not appear to be a valid URL", label="invalid url")
})