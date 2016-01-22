spocc
========



[![Build Status](https://api.travis-ci.org/ropensci/spocc.png)](https://travis-ci.org/ropensci/spocc)
[![Build status](https://ci.appveyor.com/api/projects/status/lrscgpxs0n925t83?svg=true)](https://ci.appveyor.com/project/sckott/spocc)
[![codecov.io](https://codecov.io/github/ropensci/spocc/coverage.svg?branch=master)](https://codecov.io/github/ropensci/spocc?branch=master)
[![rstudio mirror downloads](http://cranlogs.r-pkg.org/badges/spocc?color=FAB657)](https://github.com/metacran/cranlogs.app)
[![cran version](http://www.r-pkg.org/badges/version/spocc)](http://cran.rstudio.com/web/packages/spocc)


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
#> Occurrences - Found: 529,026, Returned: 100
#> Search type: Scientific
#>   gbif: Accipiter striatus (100)
```


```r
out$gbif # just gbif data
#> Species [Accipiter striatus (100)] 
#> First 10 rows of [Accipiter_striatus]
#> 
#>                  name  longitude latitude prov
#> 1  Accipiter striatus  -73.23131 44.28476 gbif
#> 2  Accipiter striatus -135.32684 57.05398 gbif
#> 3  Accipiter striatus -116.67145 32.94147 gbif
#> 4  Accipiter striatus  -95.50117 29.76086 gbif
#> 5  Accipiter striatus  -75.65139 45.44557 gbif
#> 6  Accipiter striatus -103.01232 36.38905 gbif
...
```

## Pass options to each data source

Get fine-grained detail over each data source by passing on parameters to the packge rebird in this example.


```r
out <- occ(query = 'Setophaga caerulescens', from = 'ebird', ebirdopts = list(region = 'US'))
out$ebird # just ebird data
#> Species [Setophaga caerulescens (22)] 
#> First 10 rows of [Setophaga_caerulescens]
#> 
#>                      name longitude latitude  prov               obsDt
#> 1  Setophaga caerulescens -80.12837 26.95568 ebird 2016-01-21 14:30:00
#> 2  Setophaga caerulescens -80.85031 25.21461 ebird 2016-01-21 14:05:00
#> 3  Setophaga caerulescens -80.40980 25.99068 ebird 2016-01-21 06:48:00
#> 4  Setophaga caerulescens -80.21406 26.27687 ebird 2016-01-20 09:30:00
#> 5  Setophaga caerulescens -80.41000 25.12806 ebird 2016-01-20 08:45:00
#> 6  Setophaga caerulescens -81.78261 24.55572 ebird 2016-01-20 08:30:00
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
#> 3 Setophaga caerulescens -77.06987 38.83266 gbif 2015-05-05 17:13:00
#> 4 Setophaga caerulescens -81.69378 36.14885 gbif 2015-05-01 22:00:00
#> 5 Setophaga caerulescens -76.30042 42.43431 gbif 2015-05-08 22:00:00
#> 6 Setophaga caerulescens -74.44134 40.51806 gbif 2015-05-05 22:00:00
#>          key
#> 1 1088930021
#> 2 1088954620
#> 3 1088980050
#> 4 1122965432
#> 5 1147045067
#> 6 1211969844
#>                       name longitude latitude  prov                date
#> 167 Setophaga caerulescens -71.21852 42.28859 ebird 2016-01-14 14:00:00
#> 168 Setophaga caerulescens -80.44960 25.55820 ebird 2016-01-13 07:55:00
#> 169 Setophaga caerulescens -80.34988 27.16120 ebird 2016-01-12 16:00:00
#> 170 Setophaga caerulescens -80.43668 25.66582 ebird 2016-01-12 11:30:00
#> 171 Setophaga caerulescens -80.27130 25.67640 ebird 2016-01-10 10:33:00
#> 172 Setophaga caerulescens -80.11240 26.07110 ebird 2016-01-09 09:00:00
#>          key
#> 167 L4119294
#> 168  L127428
#> 169 L2624377
#> 170 L4063054
#> 171  L127426
#> 172  L127419
```

## Clean data

All data cleaning functionality is in a new package [scrubr](https://github.com/ropenscilabs/scrubr) - not yet on CRAN.

## Make maps

All mapping functionality is now in a separate package [mapr](https://github.com/ropensci/mapr) (formerly known as `spoccutils`), to make `spocc` easier to maintain.

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
