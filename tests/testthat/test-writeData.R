context("write Socrata datasets")

socrataEmail <- Sys.getenv("SOCRATA_EMAIL", "")
socrataPassword <- Sys.getenv("SOCRATA_PASSWORD", "")

test_that("add a row to a dataset", {
	datasetToAddToUrl <- "https://soda.demo.socrata.com/resource/xh6g-yugi.json"

	# populate df_in with two columns, each with a random number
	x <- sample(-1000:1000, 1)
	y <- sample(-1000:1000, 1)
	df_in <- data.frame(x,y)

	# write to dataset
	write.socrata(df_in,datasetToAddToUrl,"UPSERT",socrataEmail,socrataPassword)

	# read from dataset and store last (most recent) row for comparisons / tests
	df_out <- read.socrata(url = datasetToAddToUrl, email = socrataEmail, password = socrataPassword)
	df_out_last_row <- tail(df_out, n=1)

	expect_equal(df_in$x, as.numeric(df_out_last_row$x), label = "x value")
	expect_equal(df_in$y, as.numeric(df_out_last_row$y), label = "y value")
})


test_that("fully replace a dataset", {
	datasetToReplaceUrl <- "https://soda.demo.socrata.com/resource/kc76-ybeq.json"

	# populate df_in with two columns of random numbers
	x <- sample(-1000:1000, 5)
	y <- sample(-1000:1000, 5)
	df_in <- data.frame(x,y)

	# write to dataset
	write.socrata(df_in,datasetToReplaceUrl,"REPLACE",socrataEmail,socrataPassword)

	# read from dataset for comparisons / tests
	df_out <- read.socrata(url = datasetToReplaceUrl, email = socrataEmail, password = socrataPassword)

	expect_equal(ncol(df_in), ncol(df_out), label="columns")
	expect_equal(nrow(df_in), nrow(df_out), label="rows")
	expect_equal(df_in$x, as.numeric(df_out$x), label = "x values")
	expect_equal(df_in$y, as.numeric(df_out$y), label = "y values")
})
