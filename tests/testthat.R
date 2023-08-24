
## LOAD REQUIRED LIBRARIES

library(testthat)
library(RSocrata)
library(httr)
library(jsonlite)
library(mime)
library(plyr)

## Set credentials for testing private datasets and write functionality
## The related tests are not currently run due to a lack of vendor support, 
## see issue #174 for details, although it's hoped to be resolved in a 
## future release. 
Sys.setenv(SOCRATA_EMAIL="mark.silverberg+soda.demo@socrata.com")
Sys.setenv(SOCRATA_PASSWORD="7vFDsGFDUG")


## RUN TESTS
## This command will run all files matching test*.R in `./tests`, unless 
## the tests are skipped globally or individually. 
## Note: Run locally with `devtools::check()`
## Note: Run this to test as CRAN: Sys.setenv(NOT_CRAN=FALSE)

test_check("RSocrata")



