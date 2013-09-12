# RUnit tests
# 
# Author: Hugh 2013-07-15
###############################################################################

library('RUnit')

source("R/RSocrata.R")

test.readSocrataCsv <- function() {
	df <- read.socrata('http://soda.demo.socrata.com/resource/4tka-6guv.csv')
	checkEquals(1007, nrow(df), "rows")
	checkEquals(9, ncol(df), "columns")
}

test.readSocrataJson <- function() {
	df <- read.socrata('http://soda.demo.socrata.com/resource/4tka-6guv.json')
	checkEquals(1007, nrow(df), "rows")
	checkEquals(11, ncol(df), "columns")
}

test.readSoQL <- function() {
	df <- read.socrata('http://soda.demo.socrata.com/resource/4tka-6guv.csv?$select=region')
	checkEquals(1007, nrow(df), "rows")
	checkEquals(1, ncol(df), "columns")
}

test.readSoQLColumnNotFound <- function() {
	# SoQL API uses field names, not human names
	checkException(read.socrata('http://soda.demo.socrata.com/resource/4tka-6guv.csv?$select=Region'))
}

test.readSocrataCalendarDate <- function() {
	df <- read.socrata('http://soda.demo.socrata.com/resource/4tka-6guv.csv')
	dt <- df$Datetime[1] # "2012-09-14 22:38:01"
	checkEquals("POSIXlt", class(dt)[1], "data type of a date")
	checkEquals(2012, dt$year + 1900, "year")
	checkEquals(9, dt$mon + 1, "month")
	checkEquals(14, dt$mday, "day")
	checkEquals(22, dt$hour, "hours")
	checkEquals(38, dt$min, "minutes")
	checkEquals(1, dt$sec, "seconds")
}

test.suite <- defineTestSuite("test Socrata SODA interface",
		dirs = file.path("R/tests"),
		testFileRegexp = '^test.*\\.R')

runAllTests <- function() {
	test.result <- runTestSuite(test.suite)
	printTextProtocol(test.result) 
}
