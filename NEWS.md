### 1.1 
Add check for valid Socrata resource URL. Add check for supported download file format. Add support for Socrata short dates.

### 1.2 
Use comma-separated file format for Socrata downloads.

### 1.3 
* Added support for human-readable URL. Users can now copy and paste URLs of Socrata-hosted datasets, which will be transformed into a valid SoDA API web query. 

* Added additional RUnit tests to validate new functionality.

### 1.4 
Add json file format for Socrata downloads. Switch to `RJSONIO` from `rjson`. 

### 1.5 Several changes:

* Swapped to ```jsonlite``` from ```RJSONIO```
* Added handling for long and short dates
* Added unit test for reading private datasets

### 1.5.1 
Deprecated ```httr::guess_media()``` and implemented ```mime::guess_type()```

### 1.6.0 Several changes:

* New function, ```ls.socrata``` to list all datasets on a Socrata portal.
* New optional argument, ```app_token```, which lets users supply an API token while using ```read.socrata()``` to minimize throttling.
* Repairs a bug where ```read.socrata``` failed when reading in a date with a column, but there are null values in that column.
* Minor changes to the DESCRIPTION documentation to point users to GitHub for issues and provides new contact information.

### 1.6.1 Bug fixes:

* Resolved potential [name collision issue](https://github.com/Chicago/RSocrata/issues/42)
* Cleaned-up documentation with contributor instructions [#23](https://github.com/Chicago/RSocrata/issues/23) and [#28](https://github.com/Chicago/RSocrata/issues/28))
* Moved test coverage in `RUnit` to `testthat` and implemented code coverage monitoring ([#41](https://github.com/Chicago/RSocrata/issues/41))
* Clean-up DESCRIPTION ([#40](https://github.com/Chicago/RSocrata/issues/40))
* Add continuous integration for Windows ([#39](https://github.com/Chicago/RSocrata/issues/39))
* Migrate Travis-CI to "proper" R YAML ([#46](https://github.com/Chicago/RSocrata/issues/46))







