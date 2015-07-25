library(testthat)
library(RSocrata)
library(httr)
library(jsonlite)
library(mime)

context("read Socrata")

test_that("read Socrata CSV", {
  df <- read.socrata('https://soda.demo.socrata.com/resource/4334-bgaj.csv')
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(9, ncol(df), label="columns")
})

test_that("read Socrata JSON", {
  df <- read.socrata(url = 'https://soda.demo.socrata.com/resource/4334-bgaj.json')
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(11, ncol(df), label="columns")
})

test_that("read Socrata No Scheme", {
  expect_error(read.socrata('soda.demo.socrata.com/resource/4334-bgaj.csv'))
})

test_that("read SoQL", {
  df <- read.socrata('http://soda.demo.socrata.com/resource/4334-bgaj.csv?$select=region')
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(1, ncol(df), label="columns")
})

test_that("read SoQL Column Not Found (will fail)", {
  # SoQL API uses field names, not human names
  expect_error(read.socrata('http://soda.demo.socrata.com/resource/4334-bgaj.csv?$select=Region'))
})

test_that("URL is private (Unauthorized) (will fail)", {
  expect_error(read.socrata('http://data.cityofchicago.org/resource/j8vp-2qpg.json'))
})

test_that("read Socrata Human Readable", {
  df <- read.socrata(url="https://soda.demo.socrata.com/dataset/USGS-Earthquake-Reports/4334-bgaj")
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(9, ncol(df), label="columns")
})

test_that("format is not supported", {
  # Unsupported data formats
  expect_error(read.socrata('http://soda.demo.socrata.com/resource/4334-bgaj.xml'))
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
})

test_that("readAPIConflictHumanReadable", {
  df <- read.socrata('https://soda.demo.socrata.com/dataset/USGS-Earthquake-Reports/4334-bgaj?$$app_token=ew2rEMuESuzWPqMkyPfOSGJgE', app_token="ew2rEMuESuzWPqMkyPfOSUSER")
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(9, ncol(df), label="columns")
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

# TODO
# https://github.com/Chicago/RSocrata/issues/19
test_that("A JSON test with uneven row lengths", {
  skip_on_cran()
  skip_on_travis()
  skip("Not done") # working with bare jsonlite::fromJSON
  # Both should be OK
  data <- read.socrata(url = "https://data.cityofchicago.org/resource/kn9c-c2s2.json")
  awqe <- read.socrata("http://data.ny.gov/resource/eda3-in2f.json")
  
  expect_that(ncol(data) > 10)
})

# TODO
# https://github.com/Chicago/RSocrata/issues/14
test_that("RSocrata hangs when passing along SoDA queries with small number of results ", {
  skip_on_cran()
  skip_on_travis()
  skip("Not done")
  
  df500 <- read.socrata("https://data.cityofchicago.org/resource/xzkq-xp2w.json?$limit=500") # Hangs
  df250 <- read.socrata("https://data.cityofchicago.org/resource/xzkq-xp2w.json?$limit=250") # Hangs
  df100 <- read.socrata("https://data.cityofchicago.org/resource/xzkq-xp2w.json?$limit=100") # Hangs
  df50 <- read.socrata("https://data.cityofchicago.org/resource/xzkq-xp2w.json?$limit=50") # Hangs
  df25 <- read.socrata("https://data.cityofchicago.org/resource/xzkq-xp2w.json?$limit=25") # Hangs
  df10 <- read.socrata("https://data.cityofchicago.org/resource/xzkq-xp2w.json?$limit=10") # Hangs
  df5 <- read.socrata("https://data.cityofchicago.org/resource/xzkq-xp2w.json?$limit=5") # Hangs
  df1 <- read.socrata("https://data.cityofchicago.org/resource/xzkq-xp2w.json?$limit=1") # Hangs
  df <- read.socrata("https://data.cityofchicago.org/resource/xzkq-xp2w.json") # Success

})




