library(testthat)
library(RSocrata)
library(httr)
library(jsonlite)
library(mime)

context("List datasets available from a Socrata domain")

test_that("More than 0 datasets are available from a Socrata domain to download", {
  # Makes some potentially erroneous assumptions about availability of soda.demo.socrata.com
  
  df <- ls.socrata("https://soda.demo.socrata.com")
  df.ny <- ls.socrata("https://data.ny.gov/")
  
  expect_true(nrow(df) > 0)
  expect_true(nrow(df.ny) > 10)
})


test_that("Test comparing columns against data.json specifications", {
  # https://project-open-data.cio.gov/v1.1/schema/
  
  df <- ls.socrata("https://soda.demo.socrata.com")
  core_names <- c("issued", "modified", "keyword", "landingPage", "theme", "title", 
                  "accessLevel", "distribution", "description", "identifier", 
                  "publisher", "contactPoint", "license")
  
  expect_equal(rep(TRUE, length(core_names)), core_names %in% names(df))
  # Check that all names in data.json are accounted for in ls.socrata return
  expect_equal(rep(TRUE, length(names(df))), names(df) %in% c(core_names))
})
