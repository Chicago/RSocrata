library(testthat)
library(RSocrata)
library(httr)
library(jsonlite)
library(mime)

context("write Socrata datasets")

test_that("add a row to a dataset", {
  privateResourceUrl <- "https://soda.demo.socrata.com/resource/a9g2-feh2.json"

  socrataEmail <- Sys.getenv("SOCRATA_EMAIL", "")
  socrataPassword <- Sys.getenv("SOCRATA_PASSWORD", "")

	x <- c(4)
	y <- c(16)
	df_in <- data.frame(x,y)

	write.socrata(df_in,privateResourceUrl,"UPSERT",socrataEmail,socrataPassword)

	df_out <- read.socrata(privateResourceUrl, NULL, socrataEmail, socrataPassword)
	df_out_last_row <- tail(df_out, n=1)

  expect_equal(df_in$x,as.numeric(df_out_last_row$x))
  expect_equal(df_in$y,as.numeric(df_out_last_row$y))
})

test_that("fully replace a dataset", {
  privateResourceUrl <- "https://soda.demo.socrata.com/resource/a9g2-feh2.json"

  socrataEmail <- Sys.getenv("SOCRATA_EMAIL", "")
  socrataPassword <- Sys.getenv("SOCRATA_PASSWORD", "")

	x <- c(1,2,3)
	y <- c(1,4,9)
	df_in <- data.frame(x,y)

	write.socrata(df_in,privateResourceUrl,"REPLACE",socrataEmail,socrataPassword)

	df_out <- read.socrata(privateResourceUrl, NULL, socrataEmail, socrataPassword)

  expect_equal(ncol(df_in), ncol(df_out), label="columns")
  expect_equal(nrow(df_in), nrow(df_out), label="rows")
  expect_equal(df_in$x,as.numeric(df_out$x))
  expect_equal(df_in$y,as.numeric(df_out$y))
})

