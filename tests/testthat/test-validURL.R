library(testthat)
library(RSocrata)
library(httr)
library(jsonlite)
library(mime)

context("Validate URL")

test_that("Invalid URL", {
  expect_error(read.socrata("a.fake.url.being.tested"), "a.fake.url.being.tested does not appear to be a valid URL", label="invalid url")
})

test_that("function is calling the API token specified in url", {
  expect_true(substr(validateUrl('https://soda.demo.socrata.com/dataset/USGS-Earthquake-Reports/4334-bgaj?$$app_token=ew2rEMuESuzWPqMkyPfOSGJgE', 
                                 app_token="ew2rEMuESuzWPqMkyPfOSUSER"), 70, 94) == "ew2rEMuESuzWPqMkyPfOSGJgE")
  
  expect_true(substr(validateUrl('https://soda.demo.socrata.com/resource/4334-bgaj.csv?$$app_token=ew2rEMuESuzWPqMkyPfOSGJgE', 
                                 app_token="ew2rEMuESuzWPqMkyPfOSUSER"), 70, 94) == "ew2rEMuESuzWPqMkyPfOSGJgE")
  
})