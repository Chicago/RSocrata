library(testthat)
library(RSocrata)

context("Checks metadata")

test_that("it returns some number of rows", {
  nr <- getMetadata(url = "http://data.cityofchicago.org/resource/y93d-d9e3.json")
  expect_more_than(nr[[1]], 141)
  nr2 <- getMetadata(url = "https://data.cityofchicago.org/resource/6zsd-86xi.json")
  expect_more_than(nr2[[1]], 5878398)
})



