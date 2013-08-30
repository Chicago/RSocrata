RSocrata version 0.1
====================

A tool for downloading Socrata datasets as R data frames
--------------------------------------------------------	

Provided with a URL to a dataset resource published on a [Socrata](http://www.socrata.com) webserver,
or a Socrata [SoDA (Socrata Open Data Application Program Interface) web API](http://dev.socrata.com) query,
returns an [R data frame](http://stat.ethz.ch/R-manual/R-devel/library/base/html/data.frame.html).
Converts dates to [POSIX](http://stat.ethz.ch/R-manual/R-devel/library/base/html/DateTimeClasses.html) format.
Supports CSV and [JSON](http://www.json.org/) download file formats from Socrata.
Manages the throttling of data returned from Socrata.
[RUnit](http://cran.r-project.org/web/packages/RUnit/index.html) test coverage.

### Usage example

<pre><code>
earthquakesDataFrame &lt;- read.socrata("http://soda.demo.socrata.com/resource/4tka-6guv.json")<br>
nrow(earthquakesDataFrame) # 1007 (two "pages")<br>
class(earthquakesDataFrame$Datetime[1]) # POSIXlt
</code></pre>
