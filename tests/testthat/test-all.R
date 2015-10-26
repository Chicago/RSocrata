context("read Socrata")

test_that("read Socrata CSV", {
  df <- read.socrata("https://soda.demo.socrata.com/resource/4334-bgaj.csv")
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(11, ncol(df), label="columns")
})

test_that("read Socrata JSON with HTTP", {
  df <- read.socrata(url = "https://soda.demo.socrata.com/resource/4334-bgaj.json")
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(11, ncol(df), label="columns")
})

test_that("read Socrata No Scheme", {
  expect_error(read.socrata("soda.demo.socrata.com/resource/4334-bgaj.csv"))
})

test_that("read SoQL", {
  skip("because of query")
  skip_on_cran()
  skip_on_travis()
  df <- read.socrata("http://soda.demo.socrata.com/resource/4334-bgaj.json?$select=region")
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(1, ncol(df), label="columns")
})

test_that("read SoQL", {
  skip("because of query")
  skip_on_cran()
  skip_on_travis()
  df <- read.socrata("http://soda.demo.socrata.com/resource/4334-bgaj.json?$select=region")
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(1, ncol(df), label="columns")
})

test_that("read SoQL Column Not Found (will fail)", {
  skip("because of query")
  skip_on_cran()
  skip_on_travis()
  # SoQL API uses field names, not human names
  expect_error(read.socrata("http://soda.demo.socrata.com/resource/4334-bgaj.csv?$select=Region"))
})

test_that("URL is private (Unauthorized) (will fail)", {
  expect_error(read.socrata("http://data.cityofchicago.org/resource/j8vp-2qpg.json"))
})

test_that("read human-readable Socrata URL", {
  df <- read.socrata('https://soda.demo.socrata.com/dataset/USGS-Earthquake-Reports/4334-bgaj')
  expect_equal(1007, nrow(df), label="rows")
  expect_equal(9, ncol(df), label="columns")
})

test_that("format is not supported", {
  # Unsupported data formats
  expect_message(read.socrata(url="http://soda.demo.socrata.com/resource/4334-bgaj.xml"), 
                 "BEWARE: Your suffix is no longer supported. Thus, we will automatically replace it with JSON.")
})

# https://github.com/Chicago/RSocrata/issues/19
test_that("A JSON test with uneven row lengths", {
  data <- read.socrata(url = "https://data.cityofchicago.org/resource/kn9c-c2s2.json")
  awqe <- read.socrata(url = "http://data.ny.gov/resource/eda3-in2f.json")
  # df_manual3 <- read.socrata(url="http://data.cityofchicago.org/resource/ydr8-5enu.json")
  expect_more_than(ncol(awqe), 26)
  expect_more_than(ncol(data), 8)
})

# https://github.com/Chicago/RSocrata/issues/14
test_that("RSocrata hangs when passing along SoDA queries with small number of results ", {
  skip_on_cran()
  skip_on_travis()
  skip("Test works, but is just to large & long to run it")
  
  df500 <- read.socrata(url = "https://data.cityofchicago.org/resource/xzkq-xp2w.json", limit =500) 
  df250 <- read.socrata("https://data.cityofchicago.org/resource/xzkq-xp2w.json", limit =250) 
  df100 <- read.socrata("https://data.cityofchicago.org/resource/xzkq-xp2w.json", limit =100) 
  df50 <- read.socrata("https://data.cityofchicago.org/resource/xzkq-xp2w.json", limit =50) 
  df25 <- read.socrata("https://data.cityofchicago.org/resource/xzkq-xp2w.json", limit =25) 
  df10 <- read.socrata("https://data.cityofchicago.org/resource/xzkq-xp2w.json", limit =10) 
  df5 <- read.socrata("https://data.cityofchicago.org/resource/xzkq-xp2w.json", limit =5) 
  df1 <- read.socrata("https://data.cityofchicago.org/resource/xzkq-xp2w.json", limit =1) 
  df <- read.socrata("https://data.cityofchicago.org/resource/xzkq-xp2w.json")

})




