# Run RUnit tests
# 
# Author: Hugh J. Devlin, Ph. D. 2013-08-28
###############################################################################

library('RUnit')

source('RSocrata.R')
source('tests/testRSocrata.R')

test.suite <- defineTestSuite("test Socrata SODA interface",
		dirs = file.path("tests"),
		testFileRegexp = '^test.*\\.R')

runAllTests <- function() {
	test.result <- runTestSuite(test.suite)
	printTextProtocol(test.result) 
}

