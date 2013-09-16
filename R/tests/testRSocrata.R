# RUnit tests
# 
# Author: Hugh 2013-07-15
###############################################################################

library('RUnit')

source("R/RSocrata.R")

test.posixifyLong <- function() {
	dt <- posixify("09/14/2012 10:38:01 PM")
	checkEquals("POSIXlt", class(dt)[1], "first data type of a date")
	checkEquals(2012, dt$year + 1900, "year")
	checkEquals(9, dt$mon + 1, "month")
	checkEquals(14, dt$mday, "day")
	checkEquals(22, dt$hour, "hours")
	checkEquals(38, dt$min, "minutes")
	checkEquals(1, dt$sec, "seconds")
}

test.posixifyShort <- function() {
	dt <- posixify("09/14/2012")
	checkEquals("POSIXlt", class(dt)[1], "first data type of a date")
	checkEquals(2012, dt$year + 1900, "year")
	checkEquals(9, dt$mon + 1, "month")
	checkEquals(14, dt$mday, "day")
	checkEquals(0, dt$hour, "hours")
	checkEquals(0, dt$min, "minutes")
	checkEquals(0, dt$sec, "seconds")
}

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

test.readSocrataNotResource <- function() {
	# URL not a SoDA resource
	checkException(read.socrata('https://soda.demo.socrata.com/dataset/USGS-Earthquake-Reports/4tka-6guv'))
}

test.readSocrataFormatNotSupported <- function() {
	# Unsupported data format
	checkException(read.socrata('http://soda.demo.socrata.com/resource/4tka-6guv.xml'))
}

test.readSocrataCalendarDateLong <- function() {
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

test.readSocrataCalendarDateShort <- function() {
	df <- read.socrata('http://data.cityofchicago.org/resource/y93d-d9e3.csv?$order=debarment_date')
	dt <- df$DEBARMENT.DATE[1] # "05/21/1981"
	checkEquals("POSIXlt", class(dt)[1], "data type of a date")
	checkEquals(81, dt$year, "year")
	checkEquals(5, dt$mon + 1, "month")
	checkEquals(21, dt$mday, "day")
	checkEquals(0, dt$hour, "hours")
	checkEquals(0, dt$min, "minutes")
	checkEquals(0, dt$sec, "seconds")
}

test.suite <- defineTestSuite("test Socrata SODA interface",
		dirs = file.path("R/tests"),
		testFileRegexp = '^test.*\\.R')

runAllTests <- function() {
	test.result <- runTestSuite(test.suite)
	printTextProtocol(test.result) 
}
