
# Load required libraries
library(testthat)
library(RSocrata)

# Define the URL for testing the Socrata API availability
# NOTE: This URL is subject to change, pending a definitive endpoint for testing.
# Consult with the Socrata Team or refer to the latest documentation for the correct URL.
socrata_status_test_url <- "https://data.cityofchicago.org/resource/xzkq-xp2w.json"

# Make a GET request to the specified URL and store the response
socrata_status_response <- httr::GET(socrata_status_test_url)


# Check the HTTP status code of the response
# If it's 200 (OK), then the API is available and tests will be executed
# If the status code is different, the tests will be skipped, and a message 
# will be printed
if (httr::status_code(socrata_status_response) == 200) {
  test_check("RSocrata") # Run the tests for the RSocrata package
} else {
  message("Socrata API is unavailable, skipping tests.") # Print a message if the API is unavailable
}
