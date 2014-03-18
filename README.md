RSocrata
========

A tool for downloading Socrata datasets as R data frames
--------------------------------------------------------	

Provided with a URL to a dataset resource published on a [Socrata](http://www.socrata.com) webserver,
or a Socrata [SoDA (Socrata Open Data Application Program Interface) web API](http://dev.socrata.com) query,
or a Socrata "human-friendly" URL, 
returns an [R data frame](http://stat.ethz.ch/R-manual/R-devel/library/base/html/data.frame.html).
Converts dates to [POSIX](http://stat.ethz.ch/R-manual/R-devel/library/base/html/DateTimeClasses.html) format.
Supports CSV download file formats from Socrata.
Manages the throttling of data returned from Socrata.
[RUnit](http://cran.r-project.org/web/packages/RUnit/index.html) test coverage.

### Usage example 1

<pre><code>
earthquakesDataFrame &lt;- read.socrata("http://soda.demo.socrata.com/resource/4334-bgaj.csv")<br>
nrow(earthquakesDataFrame) # 1007 (two "pages")<br>
class(earthquakesDataFrame$Datetime[1]) # POSIXlt
</code></pre>

### Usage example 2

<pre><code>
earthquakesDataFrame &lt;- read.socrata("https://soda.demo.socrata.com/dataset/USGS-Earthquakes-for-2012-11-01-API-School-Demo/4334-bgaj")<br>
nrow(earthquakesDataFrame) # 1007 (two "pages")<br>
class(earthquakesDataFrame$Datetime[1]) # POSIXlt
</code></pre>

### Issues

Please report issues, request enhancements or fork us at the [City of Chicago github](https://github.com/Chicago/RSocrata/issues).

### Change log

1.1 Add check for valid Socrata resource URL. Add check for supported download file format. Add support for Socrata short dates.

1.2 Use comma-separated file format for Socrata downloads.

1.3 Added support for human-readable URL.

1.4 Add json file format for Socrata downloads. Switch to RJSONIO rom rjson. 
