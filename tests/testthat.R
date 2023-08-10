library(testthat)
library(RSocrata)

socrata_status_test_url <- "https://data.cityofchicago.org/resource/xzkq-xp2w.json"
socrata_status_response <- httr::GET(socrata_status_test_url)

if (httr::status_code(socrata_status_response) == 200) {
  test_check("RSocrata")
} else {
  message("Socrata API is unavailable, skipping tests.")
}

