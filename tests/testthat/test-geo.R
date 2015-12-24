library(testthat)
library(RSocrata)

context("Geospatial JSON")

test_that("fetches GeoJSON data", {
  geodf <- read.socrataGEO("https://data.cityofchicago.org/resource/6zsd-86xi.geojson")
  expect_equal(geodf$type, "FeatureCollection")
})
