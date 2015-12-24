library(testthat)
library(RSocrata)

context("Validate URL")

test_that("Invalid URL", {
  expect_error(read.socrata("a.fake.url.being.tested"))
})

test_that("human readable URLs are not supported", {
  expect_output(validateUrl("https://soda.demo.socrata.com/dataset/USGS-Earthquake-Reports/4334-bgaj"), 
                "https://soda.demo.socrata.com/resource/4334-bgaj.json")
})

test_that("http will get replaced with HTTPS and JSON", {
  expect_output(validateUrl("http://soda.demo.socrata.com/resource/4334-bgaj.csv"), 
                "https://soda.demo.socrata.com/resource/4334-bgaj.json")
})

test_that("URL with no suffix will get JSON one", {
  expect_output(validateUrl(url = "https://soda.demo.socrata.com/resource/4334-bgaj"), 
                "https://soda.demo.socrata.com/resource/4334-bgaj.json")
})

test_that("nothing happens with URL", {
  expect_output(validateUrl(url = "https://soda.demo.socrata.com/resource/4334-bgaj.json"), 
                "https://soda.demo.socrata.com/resource/4334-bgaj.json")
})

test_that("CSV will get replaced with JSON", {
  expect_output(validateUrl(url = "https://soda.demo.socrata.com/resource/4334-bgaj.csv"), 
                "https://soda.demo.socrata.com/resource/4334-bgaj.json")
})