spocc
========



[![Build Status](https://api.travis-ci.org/ropensci/spocc.png)](https://travis-ci.org/ropensci/spocc)
[![Build status](https://ci.appveyor.com/api/projects/status/lrscgpxs0n925t83?svg=true)](https://ci.appveyor.com/project/sckott/spocc)
[![codecov.io](https://codecov.io/github/ropensci/spocc/coverage.svg?branch=master)](https://codecov.io/github/ropensci/spocc?branch=master)
[![rstudio mirror downloads](http://cranlogs.r-pkg.org/badges/spocc?color=FAB657)](https://github.com/metacran/cranlogs.app)
[![cran version](http://www.r-pkg.org/badges/version/spocc)](https://cran.r-project.org/package=spocc)


**`spocc` = SPecies OCCurrence data**

At rOpenSci, we have been writing R packages to interact with many sources of species occurrence data, including [GBIF][gbif], [iDigBio][idigbio], [Vertnet][vertnet], [BISON][bison], [iNaturalist][inat], the [Berkeley ecoengine][ecoengine], and [AntWeb][antweb]. `spocc` is an R package to query and collect species occurrence data from many sources. The goal is to wrap functions in other R packages to make a seamless experience across data sources for the user.

The inspiration for this comes from users requesting a more seamless experience across data sources, and from our work on a similar package for taxonomy data ([taxize][taxize]).

__BEWARE:__ In cases where you request data from multiple providers, especially when including GBIF, there could be duplicate records since many providers' data eventually ends up with GBIF. See `?spocc_duplicates`, after installation, for more.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

## Installation

Stable version from CRAN


```r
install.packages("spocc", dependencies = TRUE)
```

Or the development version from GitHub


```r
install.packages("devtools")
devtools::install_github("ropensci/spocc")
```


```r
library("spocc")
```

## Basic use

Get data from GBIF


```r
(out <- occ(query = 'Accipiter striatus', from = 'gbif', limit = 100))
#> Searched: gbif
#> Occurrences - Found: 528,936, Returned: 100
#> Search type: Scientific
#>   gbif: Accipiter striatus (100)
```

Just gbif data


```r
out$gbif
#> Species [Accipiter striatus (100)] 
#> First 10 rows of [Accipiter_striatus]
#> 
#> # A tibble: 100 × 108
#>                  name  longitude latitude  prov         issues        key
#>                 <chr>      <dbl>    <dbl> <chr>          <chr>      <int>
#> 1  Accipiter striatus  -97.94314 30.04580  gbif cdround,gass84 1233600470
#> 2  Accipiter striatus  -77.05161 38.87834  gbif cdround,gass84 1270044795
#> 3  Accipiter striatus  -95.50117 29.76086  gbif cdround,gass84 1229610478
#> 4  Accipiter striatus  -96.74874 33.03102  gbif cdround,gass84 1257416040
...
```

## Pass options to each data source

Get fine-grained detail over each data source by passing on parameters to the packge rebird in this example.


```r
(out <- occ(query = 'Setophaga caerulescens', from = 'ebird', ebirdopts = list(region = 'US')))
#> Searched: ebird
#> Occurrences - Found: 0, Returned: 500
#> Search type: Scientific
#>   ebird: Setophaga caerulescens (500)
```

Just ebird data


```r
out$ebird
#> Species [Setophaga caerulescens (500)] 
#> First 10 rows of [Setophaga_caerulescens]
#> 
#> # A tibble: 500 × 12
#>                      name longitude latitude  prov      obsDt
#>                     <chr>     <dbl>    <dbl> <chr>     <date>
#> 1  Setophaga caerulescens -74.96229 38.94037 ebird 2016-10-07
#> 2  Setophaga caerulescens -81.78414 24.54900 ebird 2016-10-07
#> 3  Setophaga caerulescens -74.04066 40.62207 ebird 2016-10-07
#> 4  Setophaga caerulescens -71.13179 42.29393 ebird 2016-10-07
...
```

## Many data sources at once

Get data from many sources in a single call


```r
ebirdopts = list(region = 'US'); gbifopts = list(country = 'US')
out <- occ(query = 'Setophaga caerulescens', from = c('gbif','bison','inat','ebird'), gbifopts = gbifopts, ebirdopts = ebirdopts, limit = 50)
dat <- occ2df(out)
head(dat); tail(dat)
#> # A tibble: 6 × 6
#>                     name longitude latitude  prov       date        key
#>                    <chr>     <chr>    <chr> <chr>     <date>      <chr>
#> 1 Setophaga caerulescens -71.80166 44.53323  gbif 2016-05-31 1291120531
#> 2 Setophaga caerulescens -72.83974 44.07966  gbif 2016-05-17 1269567302
#> 3 Setophaga caerulescens -83.44952 44.25382  gbif 2016-05-07 1291149671
#> 4 Setophaga caerulescens -83.59349 41.58065  gbif 2016-05-11 1291674787
#> 5 Setophaga caerulescens -75.19615 39.95469  gbif 2016-05-11 1269552963
#> 6 Setophaga caerulescens -83.44952 44.25382  gbif 2016-05-08 1291149541
#> # A tibble: 6 × 6
#>                     name   longitude   latitude  prov       date      key
#>                    <chr>       <chr>      <chr> <chr>     <date>    <chr>
#> 1 Setophaga caerulescens -76.5798569 39.2896713 ebird 2016-10-07  L449982
#> 2 Setophaga caerulescens -76.2258053 39.0347918 ebird 2016-10-07  L126631
#> 3 Setophaga caerulescens -75.3904152 40.6363295 ebird 2016-10-07  L372101
#> 4 Setophaga caerulescens -73.9869263 40.4392518 ebird 2016-10-07  L197353
#> 5 Setophaga caerulescens   -88.21148   40.11972 ebird 2016-10-07  L251002
#> 6 Setophaga caerulescens -75.1045883 40.0237695 ebird 2016-10-07 L3694793
```

## Clean data

All data cleaning functionality is in a new package [scrubr](https://github.com/ropenscilabs/scrubr). [On CRAN](https://cran.r-project.org/package=scrubr).

## Make maps

All mapping functionality is now in a separate package [mapr](https://github.com/ropensci/mapr) (formerly known as `spoccutils`), to make `spocc` easier to maintain. [On CRAN](https://cran.r-project.org/package=mapr).

## Meta

* Please [report any issues or bugs](https://github.com/ropensci/spocc/issues).
* License: MIT
* Get citation information for `spocc` in R doing `citation(package = 'spocc')`
* Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.

[![ropensci_footer](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)

[gbif]: https://github.com/ropensci/rgbif
[vertnet]: https://github.com/ropensci/rvertnet
[bison]: https://github.com/ropensci/rbison
[inat]: https://github.com/ropensci/rinat
[taxize]: https://github.com/ropensci/taxize
[ecoengine]: https://github.com/ropensci/ecoengine
[antweb]: http://antweb.org/
[idigbio]: https://www.idigbio.org/
