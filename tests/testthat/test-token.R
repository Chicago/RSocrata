library(testthat)
library(RSocrata)
library(httr)
library(jsonlite)
library(mime)

context("Test Socrata with Token")

test_that("CSV with Token", {
  df <- read.socrata(url = "https://soda.demo.socrata.com/resource/4334-bgaj.csv", 
                     app_token="ew2rEMuESuzWPqMkyPfOSGJgE")
  
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(11, ncol(df), label="columns")  
})


test_that("it will read Socrata Human Readable URL with Token", {
  df <- read.socrata("https://soda.demo.socrata.com/dataset/USGS-Earthquake-Reports/4334-bgaj", 
                              app_token="ew2rEMuESuzWPqMkyPfOSGJgE")
  
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(11, ncol(df), label="columns")
})

test_that("API Conflict", {
  expect_error(read.socrata("https://soda.demo.socrata.com/resource/4334-bgaj.csv?$$app_token=ew2rEMuESuzWPqMkyPfOSGJgE", 
                            app_token="ew2rEMuESuzWPqMkyPfOSUSER"))
  
  # expect_equal(1007, nrow(df), label="rows")
  # expect_equal(9, ncol(df), label="columns")
})

test_that("read API Conflict HumanReadable", {
  expect_error(read.socrata("https://soda.demo.socrata.com/dataset/USGS-Earthquake-Reports/4334-bgaj?$$app_token=ew2rEMuESuzWPqMkyPfOSGJgE", 
                            app_token="ew2rEMuESuzWPqMkyPfOSUSER"))
  
  # expect_equal(1007, nrow(df), label="rows")
  # expect_equal(11, ncol(df), label="columns")
})

test_that("incorrect API Query", {
  # The query below is missing a $ before app_token.
  expect_error(read.socrata("https://soda.demo.socrata.com/resource/4334-bgaj.csv?$app_token=ew2rEMuESuzWPqMkyPfOSGJgE"))
  
  df <- read.socrata("https://soda.demo.socrata.com/resource/4334-bgaj.csv", app_token= "ew2rEMuESuzWPqMkyPfOSGJgE")
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(11, ncol(df), label="columns") 
})


test_that("incorrect API Query Human Readable", {
  # The query below is missing a $ before app_token.
  expect_error(read.socrata("https://soda.demo.socrata.com/dataset/USGS-Earthquake-Reports/4334-bgaj?$app_token=ew2rEMuESuzWPqMkyPfOSGJgE"))
  
  df <- read.socrata("https://soda.demo.socrata.com/resource/4334-bgaj", app_token= "ew2rEMuESuzWPqMkyPfOSGJgE")
  expect_equal(1007, nrow(df), label = "rows")
  expect_equal(11, ncol(df), label = "columns") 
})