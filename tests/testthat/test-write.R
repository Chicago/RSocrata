
context("write Socrata datasets")


## DEFINE PARAMETERS FOR TESTS 

socrataEmail <- Sys.getenv("SOCRATA_EMAIL")
socrataPassword <- Sys.getenv("SOCRATA_PASSWORD")


## RUN TESTS

test_that("add a row to a dataset", {
  skip('See Issue #174')
  datasetToAddToUrl <- "https://soda.demo.socrata.com/resource/xh6g-yugi.json"
  
  # populate df_in with two columns, each with a random number
  x <- sample(-1000:1000, 1)
  y <- sample(-1000:1000, 1)
  df_in <- data.frame(x,y)
  
  # write to dataset
  res <- write.socrata(df_in,datasetToAddToUrl,"UPSERT",socrataEmail,socrataPassword)
  
  # Check that the dataset was written without error
  expect_equal(res$status_code, 200L)
  
})


test_that("fully replace a dataset", {
  skip('See Issue #174')
  datasetToReplaceUrl <- "https://soda.demo.socrata.com/resource/kc76-ybeq.json"
  
  # populate df_in with two columns of random numbers
  x <- sample(-1000:1000, 5)
  y <- sample(-1000:1000, 5)
  df_in <- data.frame(x,y)
  
  # write to dataset
  res <- write.socrata(df_in,datasetToReplaceUrl,"REPLACE",socrataEmail,socrataPassword)
  
  # Check that the dataset was written without error
  expect_equal(res$status_code, 200L)
})
