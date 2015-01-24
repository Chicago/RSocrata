RSocrata
========

Master: [![Build Status - Master](https://api.travis-ci.org/Chicago/RSocrata.png?branch=master)](https://travis-ci.org/Chicago/RSocrata)

Dev: [![Build Status - Dev](https://api.travis-ci.org/Chicago/RSocrata.png?branch=dev)](https://travis-ci.org/Chicago/RSocrata)

A tool for downloading Socrata datasets as R data frames
--------------------------------------------------------	

Provided with a URL to a dataset resource published on a [Socrata](http://www.socrata.com) webserver,
or a Socrata [SoDA (Socrata Open Data Application Program Interface) web API](http://dev.socrata.com) query,
or a Socrata "human-friendly" URL, ```read.socrata()```
returns an [R data frame](http://stat.ethz.ch/R-manual/R-devel/library/base/html/data.frame.html).
Converts dates to [POSIX](http://stat.ethz.ch/R-manual/R-devel/library/base/html/DateTimeClasses.html) format.
Supports CSV and JSON download file formats from Socrata.
Manages the throttling of data returned from Socrata and allows users to provide an [application token](http://dev.socrata.com/docs/app-tokens.html).
Supports [SoDA query parameters](http://dev.socrata.com/docs/queries.html) in the URL string for further filtering, sorting, and queries.

Use ```ls.socrata()``` to list all datasets available on a Socrata webserver.

[RUnit](http://cran.r-project.org/web/packages/RUnit/index.html) test coverage.

### Example: Reading SoDA valid URLs
```r
earthquakesDataFrame <- read.socrata("http://soda.demo.socrata.com/resource/4334-bgaj.csv")<br>
nrow(earthquakesDataFrame) # 1007 (two "pages")<br>
class(earthquakesDataFrame$Datetime[1]) # POSIXlt
```

### Example: Reading "human-readable" URLs
```r
earthquakesDataFrame <- read.socrata("https://soda.demo.socrata.com/dataset/USGS-Earthquakes-for-2012-11-01-API-School-Demo/4334-bgaj")<br>
nrow(earthquakesDataFrame) # 1007 (two "pages")<br>
class(earthquakesDataFrame$Datetime[1]) # POSIXlt
```

### Example: Using API key to read datasets
```r
token <- "ew2rEMuESuzWPqMkyPfOSGJgE"
earthquakesDataFrame <- read.socrata("http://soda.demo.socrata.com/resource/4334-bgaj.csv", app_token = token)
nrow(earthquakesDataFrame)
```

### Example: List all datasets on portal
```r
allSitesDataFrame <- ls.socrata("https://soda.demo.socrata.com")
nrow(allSitesDataFrame) # Number of datasets
allSitesDataFrame$title # Names of each dataset
```

### Issues

Please report issues, request enhancements or fork us at the [City of Chicago github](https://github.com/Chicago/RSocrata/issues).

### Change log

1.1 Add check for valid Socrata resource URL. Add check for supported download file format. Add support for Socrata short dates.

1.2 Use comma-separated file format for Socrata downloads.

1.3 Added support for human-readable URL.

1.4 Add json file format for Socrata downloads. Switch to RJSONIO rom rjson. 

1.5 Several changes:
* Swapped ```jsonlite``` to ```RJSONIO```
* Added handling for long and short dates
* Added unit test for reading private datasets

1.5.1 Deprecated ```httr::guess_media()``` and implemented ```httr::guess_type()```
