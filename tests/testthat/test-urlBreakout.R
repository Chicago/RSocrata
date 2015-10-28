context("Parsimonious URL calls")

test_that("read from Socrata domain", {
  df <- read.socrata(domain = "http://soda.demo.socrata.com",
                     fourByFour = "4334-bgaj")
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(11, ncol(df), label="columns")
})

test_that("read from Socrata domain, trailing slash", {
  df <- read.socrata(domain = "http://soda.demo.socrata.com/",
                     fourByFour = "4334-bgaj")
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(11, ncol(df), label="columns")
})

test_that("read from Socrata domain, SSL", {
  df <- read.socrata(domain = "https://soda.demo.socrata.com",
                     fourByFour = "4334-bgaj")
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(11, ncol(df), label="columns")
})

test_that("read from Socrata domain, SSL with trailing slash", {
  df <- read.socrata(domain = "http://soda.demo.socrata.com/",
                     fourByFour = "4334-bgaj")
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(11, ncol(df), label="columns")
})