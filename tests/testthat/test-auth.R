
context("Test reading private Socrata dataset with email and password")


## DEFINE PARAMETERS FOR TESTS 

privateResourceToReadCsvUrl <- "https://soda.demo.socrata.com/resource/a9g2-feh2.csv"
privateResourceToReadJsonUrl <- "https://soda.demo.socrata.com/resource/a9g2-feh2.json"

socrataEmail <- Sys.getenv("SOCRATA_EMAIL")
socrataPassword <- Sys.getenv("SOCRATA_PASSWORD")


## RUN TESTS

test_that("URL is private (Unauthorized) (will fail)", {
  
  skip_on_cran()
  
  expect_error(read.socrata('https://data.cityofchicago.org/resource/j8vp-2qpg.json'))
})


test_that("read Socrata CSV that requires a login", {
  skip('See Issue #174')
  # should error when no email and password are sent with the request
  expect_error(read.socrata(url = privateResourceToReadCsvUrl))
  # try again, this time with email and password in the request
  df <- read.socrata(url = privateResourceToReadCsvUrl, 
                     email = socrataEmail, 
                     password = socrataPassword)
  # tests
  expect_equal(2, ncol(df), label="columns")
  expect_equal(3, nrow(df), label="rows")
})

test_that("read Socrata JSON that requires a login", {
  skip('See Issue #174')
  # should error when no email and password are sent with the request
  expect_error(read.socrata(url = privateResourceToReadJsonUrl))
  # try again, this time with email and password in the request
  df <- read.socrata(url = privateResourceToReadJsonUrl, 
                     email = socrataEmail, 
                     password = socrataPassword)
  # tests
  expect_equal(2, ncol(df), label="columns")
  expect_equal(3, nrow(df), label="rows")
})


