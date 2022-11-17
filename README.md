RSocrata
========

[![Gitter](https://badges.gitter.im/gitterHQ/gitter.svg)](https://gitter.im/Chicago/RSocrata)
[![downloads](https://cranlogs.r-pkg.org/badges/RSocrata)](https://CRAN.R-project.org/package=RSocrata)
[![cran version](https://www.r-pkg.org/badges/version/RSocrata)](https://CRAN.R-project.org/package=RSocrata)

**Master** 

Stable beta branch. Test about-to-be-released features in a stable pre-release build before it is submitted to CRAN.

[![Linux build - Master](https://img.shields.io/travis/Chicago/RSocrata/master.svg?style=flat-square&label=Linux%20build)](https://travis-ci.org/Chicago/RSocrata)[![Windows build - Master](https://img.shields.io/appveyor/ci/tomschenkjr/RSocrata/master.svg?style=flat-square&label=Windows%20build)](https://ci.appveyor.com/project/tomschenkjr/rsocrata/branch/master)[![Coverage - Master](https://img.shields.io/coveralls/Chicago/RSocrata/master.svg?style=flat-square&label=Coverage)](https://coveralls.io/github/Chicago/RSocrata?branch=master)

**Dev**

"Nightly" alpha branch. Test the latest features and bug fixes -- enjoy at your own risk.

[![Linux build - Dev](https://img.shields.io/travis/Chicago/RSocrata/dev.svg?style=flat-square&label=Linux%20build)](https://travis-ci.org/Chicago/RSocrata)[![Windows build - Dev](https://img.shields.io/appveyor/ci/tomschenkjr/RSocrata/dev.svg?style=flat-square&label=Windows%20build)](https://ci.appveyor.com/project/tomschenkjr/rsocrata/branch/dev)[![Coverage - Dev](https://img.shields.io/coveralls/Chicago/RSocrata/dev.svg?style=flat-square&label=Coverage)](https://coveralls.io/github/Chicago/RSocrata?branch=dev)

A tool for downloading and uploading Socrata datasets
-----------------------------------------------------

Provided with a URL to a dataset resource published on a [Socrata](https://www.tylertech.com/products/data-insights) webserver,
or a Socrata [SoDA (Socrata Open Data Application Program Interface) web API](https://dev.socrata.com) query,
or a Socrata "human-friendly" URL, ```read.socrata()```
returns an [R data frame](https://stat.ethz.ch/R-manual/R-devel/library/base/html/data.frame.html).
Converts dates to [POSIX](https://stat.ethz.ch/R-manual/R-devel/library/base/html/DateTimeClasses.html) format.
Supports CSV and JSON download file formats from Socrata.
Manages the throttling of data returned from Socrata and allows users to provide an [application token](https://dev.socrata.com/docs/app-tokens.html).
Supports [SoDA query parameters](https://dev.socrata.com/docs/queries.html) in the URL string for further filtering, sorting, and queries.
Upload data to Socrata data portals using "upsert" and "replace" methods.

Use ```ls.socrata()``` to list all datasets available on a Socrata webserver.

[testthat](https://cran.r-project.org/package=testthat) test coverage.

## Installation


To get the current released version from CRAN:

```R
install.packages("RSocrata")
```

The most recent beta with soon-to-be-released changes can be installed from GitHub:

```R
# install.packages("devtools")
devtools::install_github("Chicago/RSocrata")
```

The "nightly" version with the most recent bug fixes and features is also available. This version is always an alpha and may contain significant bugs. You can install it from the `dev` branch from GitHub:

```R
# install.packages("devtools")
devtools::install_github("Chicago/RSocrata", ref="dev")
```

Examples
--------

### Reading SoDA valid URLs
```r
earthquakesDataFrame <- read.socrata("https://soda.demo.socrata.com/resource/4334-bgaj.csv")
nrow(earthquakesDataFrame) # 1007 (two "pages")
class(earthquakesDataFrame$Datetime[1]) # POSIXlt
```

### Reading "human-readable" URLs
```r
earthquakesDataFrame <- read.socrata("https://soda.demo.socrata.com/dataset/USGS-Earthquakes-for-2012-11-01-API-School-Demo/4334-bgaj")
nrow(earthquakesDataFrame) # 1007 (two "pages")
class(earthquakesDataFrame$Datetime[1]) # POSIXlt
```

### Using API key to read datasets
```r
token <- "ew2rEMuESuzWPqMkyPfOSGJgE"
earthquakesDataFrame <- read.socrata("https://soda.demo.socrata.com/resource/4334-bgaj.csv", app_token = token)
nrow(earthquakesDataFrame)
```

### Download private datasets from portal
```r
# Store user email and password
socrataEmail <- Sys.getenv("SOCRATA_EMAIL", "mark.silverberg+soda.demo@socrata.com")
socrataPassword <- Sys.getenv("SOCRATA_PASSWORD", "7vFDsGFDUG")

privateResourceToReadCsvUrl <- "https://soda.demo.socrata.com/resource/a9g2-feh2.csv" # dataset

read.socrata(url = privateResourceToReadCsvUrl, email = socrataEmail, password = socrataPassword)
```

### List all datasets on portal
```r
allSitesDataFrame <- ls.socrata("https://soda.demo.socrata.com")
nrow(allSitesDataFrame) # Number of datasets
allSitesDataFrame$title # Names of each dataset
```

### Upload data to portal
```r
# Store user email and password
socrataEmail <- Sys.getenv("SOCRATA_EMAIL", "mark.silverberg+soda.demo@socrata.com")
socrataPassword <- Sys.getenv("SOCRATA_PASSWORD", "7vFDsGFDUG")

datasetToAddToUrl <- "https://soda.demo.socrata.com/resource/xh6g-yugi.json" # dataset
 
# Generate some data
x <- sample(-1000:1000, 1)
y <- sample(-1000:1000, 1)
df_in <- data.frame(x,y)
 
# Upload to Socrata
write.socrata(df_in,datasetToAddToUrl,"UPSERT",socrataEmail,socrataPassword)
```

## Issues

Please report issues, request enhancements or fork us at the [City of Chicago github](https://github.com/Chicago/RSocrata/issues).

## Contributing

If you would like to contribute to this project, please see the [contributing documentation](https://github.com/Chicago/RSocrata/blob/master/CONTRIBUTING.md) and the [product roadmap](https://github.com/Chicago/RSocrata/wiki/Roadmap#planned-releases).
