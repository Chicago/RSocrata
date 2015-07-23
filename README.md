RSocrata
========

**Master** 

[![Linux build - Master](https://img.shields.io/travis/Chicago/RSocrata/master.svg?style=flat-square&label=Linux build)](https://travis-ci.org/Chicago/RSocrata)[![Windows build - Master](https://img.shields.io/appveyor/ci/tomschenkjr/RSocrata/master.svg?style=flat-square&label=Windows build)](https://ci.appveyor.com/project/tomschenkjr/rsocrata/branch/master)[![Coverage - Master](https://img.shields.io/coveralls/Chicago/RSocrata/master.svg?style=flat-square&label=Coverage - Master)](https://coveralls.io/r/Chicago/RSocrata?branch=master)

**Dev**

[![Linux build - Dev](https://img.shields.io/travis/Chicago/RSocrata/dev.svg?style=flat-square&label=Linux build)](https://travis-ci.org/Chicago/RSocrata)[![Windows build - Dev](https://img.shields.io/appveyor/ci/tomschenkjr/RSocrata/dev.svg?style=flat-square&label=Windows build)](https://ci.appveyor.com/project/tomschenkjr/rsocrata/branch/dev)[![Coverage - Dev](https://img.shields.io/coveralls/Chicago/RSocrata/dev.svg?style=flat-square&label=Coverage - Dev)](https://coveralls.io/r/Chicago/RSocrata?branch=dev)

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

This package uses [testthat](http://cran.r-project.org/package=testthat) test coverage.

### Installation

Use `devtools` to install the latest version from Github:

```
library(devtools)
devtools::install_github("Chicago/RSocrata")
```

**OR** 

on [CRAN](http://cran.r-project.org/package=RSocrata)

**Beware**:

For the support of `GeoJSON`, it is necessary to install [geojsonio](https://github.com/ropensci/geojsonio) correctly!
This depends on packages such as `rgdal` & `rgeos` (both are on CRAN), which on Linux you will need to install through `apt-get`:

`sudo apt-get install libgdal1-dev libgdal-dev libgeos-c1 libproj-dev`

Then install both of them:

```
install.packages("rgdal")
install.packages("rgeos")
```

### Example: Reading SoDA valid URLs
```r
earthquakesDataFrame <- read.socrata("http://soda.demo.socrata.com/resource/4334-bgaj.csv")
nrow(earthquakesDataFrame) # 1007 (two "pages")
class(earthquakesDataFrame$Datetime[1]) # POSIXlt
```

### Example: Reading "human-readable" URLs
```r
earthquakesDataFrame <- read.socrata("https://soda.demo.socrata.com/dataset/USGS-Earthquakes-for-2012-11-01-API-School-Demo/4334-bgaj")
nrow(earthquakesDataFrame) # 1007 (two "pages")
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

### Contributing

If you would like to contribute to this project, please see the [contributing documentation](CONTRIBUTING.md) and the [product roadmap](https://github.com/Chicago/RSocrata/wiki/Roadmap#planned-releases).
