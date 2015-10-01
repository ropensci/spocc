spocc
========



[![Build Status](https://api.travis-ci.org/ropensci/spocc.png)](https://travis-ci.org/ropensci/spocc)
[![Build status](https://ci.appveyor.com/api/projects/status/lrscgpxs0n925t83?svg=true)](https://ci.appveyor.com/project/sckott/spocc)
[![codecov.io](https://codecov.io/github/ropensci/spocc/coverage.svg?branch=master)](https://codecov.io/github/ropensci/spocc?branch=master)
[![rstudio mirror downloads](http://cranlogs.r-pkg.org/badges/spocc?color=FAB657)](https://github.com/metacran/cranlogs.app)
[![cran version](http://www.r-pkg.org/badges/version/spocc)](http://cran.rstudio.com/web/packages/spocc)


**`spocc` = SPecies OCCurrence data**

At rOpenSci, we have been writing R packages to interact with many sources of species occurrence data, including [GBIF][gbif], [Vertnet][vertnet], [BISON][bison], [iNaturalist][inat], the [Berkeley ecoengine][ecoengine],  [AntWeb][antweb]. `spocc` is an R package to query and collect species occurrence data from many sources. The goal is to wrap functions in other R packages to make a seamless experience across data sources for the user.

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
#> Occurrences - Found: 447,930, Returned: 100
#> Search type: Scientific
#>   gbif: Accipiter striatus (100)
```


```r
out$gbif # just gbif data
#> Species [Accipiter striatus (100)] 
#> First 10 rows of [Accipiter_striatus]
#> 
#>                  name  longitude latitude prov
#> 1  Accipiter striatus    0.00000  0.00000 gbif
#> 2  Accipiter striatus  -71.06930 42.34816 gbif
#> 3  Accipiter striatus  -97.25801 32.89462 gbif
#> 4  Accipiter striatus  -72.54554 41.22175 gbif
#> 5  Accipiter striatus -104.83266 21.47117 gbif
#> 6  Accipiter striatus  -75.17209 40.34000 gbif
...
```

## Pass options to each data source

Get fine-grained detail over each data source by passing on parameters to the packge rebird in this example.


```r
out <- occ(query = 'Setophaga caerulescens', from = 'ebird', ebirdopts = list(region = 'US'))
out$ebird # just ebird data
#> Species [Setophaga caerulescens (500)] 
#> First 10 rows of [Setophaga_caerulescens]
#> 
#>                      name longitude latitude  prov
#> 1  Setophaga caerulescens -78.67718 35.78526 ebird
#> 2  Setophaga caerulescens -80.35220 36.19311 ebird
#> 3  Setophaga caerulescens -73.80837 41.16219 ebird
#> 4  Setophaga caerulescens -73.96957 40.77712 ebird
#> 5  Setophaga caerulescens -80.29959 36.15534 ebird
#> 6  Setophaga caerulescens -84.73439 41.19316 ebird
...
```

## Many data sources at once

Get data from many sources in a single call


```r
ebirdopts = list(region = 'US'); gbifopts = list(country = 'US')
out <- occ(query = 'Setophaga caerulescens', from = c('gbif','bison','inat','ebird'), gbifopts = gbifopts, ebirdopts = ebirdopts, limit = 50)
head(occ2df(out)); tail(occ2df(out))
#>                     name longitude latitude prov                date
#> 1 Setophaga caerulescens -80.82181 24.81413 gbif 2015-03-26 23:00:00
#> 2 Setophaga caerulescens -82.55674 35.63396 gbif 2015-04-21 18:51:02
#> 3 Setophaga caerulescens -81.36789 36.32292 gbif 2015-05-24 22:00:00
#> 4 Setophaga caerulescens -71.14539 42.37083 gbif 2015-05-15 11:35:56
#> 5 Setophaga caerulescens -77.06987 38.83266 gbif 2015-05-05 17:13:00
#> 6 Setophaga caerulescens -82.87321 24.62802 gbif 2015-05-06 22:00:00
#>          key
#> 1 1088930021
#> 2 1088954620
#> 3 1092899848
#> 4 1092879951
#> 5 1088980050
#> 6 1092893709
#>                       name longitude latitude  prov                date
#> 195 Setophaga caerulescens -81.71469 41.49917 ebird 2015-09-30 17:35:00
#> 196 Setophaga caerulescens -82.11295 36.64857 ebird 2015-09-30 17:30:00
#> 197 Setophaga caerulescens -83.64537 41.74374 ebird 2015-09-30 17:20:00
#> 198 Setophaga caerulescens -84.12605 39.73068 ebird 2015-09-30 16:45:00
#> 199 Setophaga caerulescens -77.73266 43.30991 ebird 2015-09-30 15:25:00
#> 200 Setophaga caerulescens -85.43134 38.16773 ebird 2015-09-30 15:00:00
#>          key
#> 195  L284586
#> 196 L2203158
#> 197 L3092222
#> 198 L2807001
#> 199  L390594
#> 200 L3468635
```

## Make maps

All mapping functionality is now in a separate package [spoccutils](https://github.com/ropensci/spoccutils), to make `spocc` easier to maintain.

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
