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
#> Occurrences - Found: 529,394, Returned: 100
#> Search type: Scientific
#>   gbif: Accipiter striatus (100)
```

Just gbif data


```r
out$gbif
#> Species [Accipiter striatus (100)] 
#> First 10 rows of [Accipiter_striatus]
#> 
#> Source: local data frame [100 x 111]
#> 
#>                  name  longitude latitude  prov              issues
#>                 <chr>      <dbl>    <dbl> <chr>               <chr>
#> 1  Accipiter striatus  -98.24809 26.10815  gbif      cdround,gass84
#> 2  Accipiter striatus  -72.48018 43.72704  gbif      cdround,gass84
#> 3  Accipiter striatus  -97.21962 32.88749  gbif      cdround,gass84
...
```

## Pass options to each data source

Get fine-grained detail over each data source by passing on parameters to the packge rebird in this example.


```r
(out <- occ(query = 'Setophaga caerulescens', from = 'ebird', ebirdopts = list(region = 'US')))
#> Searched: ebird
#> Occurrences - Found: 0, Returned: 252
#> Search type: Scientific
#>   ebird: Setophaga caerulescens (252)
```

Just ebird data


```r
out$ebird
#> Species [Setophaga caerulescens (252)] 
#> First 10 rows of [Setophaga_caerulescens]
#> 
#> Source: local data frame [252 x 12]
#> 
#>                      name longitude latitude  prov               obsDt
#>                     <chr>     <dbl>    <dbl> <chr>              <time>
#> 1  Setophaga caerulescens -78.88946 36.00959 ebird 2016-04-21 15:37:00
#> 2  Setophaga caerulescens -80.11240 26.07110 ebird 2016-04-21 14:17:00
#> 3  Setophaga caerulescens -81.54980 27.81274 ebird 2016-04-21 14:00:00
...
```

## Many data sources at once

Get data from many sources in a single call


```r
ebirdopts = list(region = 'US'); gbifopts = list(country = 'US')
out <- occ(query = 'Setophaga caerulescens', from = c('gbif','bison','inat','ebird'), gbifopts = gbifopts, ebirdopts = ebirdopts, limit = 50)
dat <- occ2df(out)
head(dat); tail(dat)
#> Source: local data frame [6 x 6]
#> 
#>                     name longitude latitude  prov                date
#>                    <chr>     <dbl>    <dbl> <chr>              <time>
#> 1 Setophaga caerulescens -80.82181 24.81413  gbif 2015-03-26 23:00:00
#> 2 Setophaga caerulescens -82.55674 35.63396  gbif 2015-04-21 18:51:02
#> 3 Setophaga caerulescens -83.19085 41.62769  gbif 2015-05-16 22:00:00
#> 4 Setophaga caerulescens -82.87321 24.62802  gbif 2015-05-06 22:00:00
#> 5 Setophaga caerulescens -71.14539 42.37083  gbif 2015-05-15 11:35:56
#> 6 Setophaga caerulescens -81.36789 36.32292  gbif 2015-05-24 22:00:00
#> Variables not shown: key <chr>.
#> Source: local data frame [6 x 6]
#> 
#>                     name longitude latitude  prov                date
#>                    <chr>     <dbl>    <dbl> <chr>              <time>
#> 1 Setophaga caerulescens -82.36339 29.66126 ebird 2016-04-20 09:42:00
#> 2 Setophaga caerulescens -81.02529 35.10243 ebird 2016-04-20 09:27:00
#> 3 Setophaga caerulescens -80.86127 36.25218 ebird 2016-04-20 09:04:00
#> 4 Setophaga caerulescens -82.78100 28.03240 ebird 2016-04-20 08:57:00
#> 5 Setophaga caerulescens -84.72965 34.16452 ebird 2016-04-20 08:52:00
#> 6 Setophaga caerulescens -81.39138 24.72999 ebird 2016-04-20 08:35:00
#> Variables not shown: key <chr>.
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
