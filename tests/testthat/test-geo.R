library(testthat)
library(RSocrata)
library(httr)
library(jsonlite)
library(mime)
library(geojsonio)

context("Geospatial JSON")

test_that("fetches GeoJSON data", {
  geodf <- read.socrataGEO("https://data.cityofchicago.org/resource/6zsd-86xi.geojson", 
                           method = "local", parse = FALSE, what = "list")
  expect_equal(geodf$type, "FeatureCollection")
})
