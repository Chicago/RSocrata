context("Test reading private Socrata dataset with email and password")

privateResourceToReadCsvUrl <- "https://soda.demo.socrata.com/resource/a9g2-feh2.csv"
privateResourceToReadJsonUrl <- "https://soda.demo.socrata.com/resource/a9g2-feh2.json"
socrataEmail <- Sys.getenv("SOCRATA_EMAIL", "")
socrataPassword <- Sys.getenv("SOCRATA_PASSWORD", "")

test_that("read Socrata CSV that requires a login", {
	# should error when no email and password are sent with the request
  expect_error(read.socrata(url = privateResourceToReadCsvUrl))
  # try again, this time with email and password in the request
  df <- read.socrata(url = privateResourceToReadCsvUrl, email = socrataEmail, password = socrataPassword)
  # tests
  expect_equal(2, ncol(df), label="columns")
  expect_equal(3, nrow(df), label="rows")
})

test_that("read Socrata JSON that requires a login", {
	# should error when no email and password are sent with the request
  expect_error(read.socrata(url = privateResourceToReadJsonUrl))
  # try again, this time with email and password in the request
  df <- read.socrata(url = privateResourceToReadJsonUrl, email = socrataEmail, password = socrataPassword)
  # tests
  expect_equal(2, ncol(df), label="columns")
  expect_equal(3, nrow(df), label="rows")
})
