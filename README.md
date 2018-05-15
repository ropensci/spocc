spocc
========



[![Build Status](https://travis-ci.org/ropensci/spocc.svg?branch=master)](https://travis-ci.org/ropensci/spocc)
[![Build status](https://ci.appveyor.com/api/projects/status/lrscgpxs0n925t83?svg=true)](https://ci.appveyor.com/project/sckott/spocc)
[![codecov.io](https://codecov.io/github/ropensci/spocc/coverage.svg?branch=master)](https://codecov.io/github/ropensci/spocc?branch=master)
[![rstudio mirror downloads](https://cranlogs.r-pkg.org/badges/spocc?color=FAB657)](https://github.com/metacran/cranlogs.app)
[![cran version](https://www.r-pkg.org/badges/version/spocc)](https://cran.r-project.org/package=spocc)


**`spocc` = SPecies OCCurrence data**

At rOpenSci, we have been writing R packages to interact with many sources of species occurrence data, including [GBIF][gbif], [Vertnet][vertnet], [BISON][bison], [iNaturalist][inat], the [Berkeley ecoengine][ecoengine], [AntWeb][antweb], and [eBird][ebird]. Other databases are out there as well, which we can pull in. `spocc` is an R package to query and collect species occurrence data from many sources. The goal is to to create a seamless search experience across data sources, as well as creating unified outputs across data sources.

`spocc` currently interfaces with ten major biodiversity repositories

1. [Global Biodiversity Information Facility (GBIF)][gbif] (via `rgbif`)
GBIF is a government funded open data repository with several partner organizations with the express goal of providing access to data on Earth's biodiversity. The data are made available by a network of member nodes, coordinating information from various participant organizations and government agencies.

2. [Berkeley Ecoengine][ecoengine] (via `ecoengine`)
The ecoengine is an open API built by the [Berkeley Initiative for Global Change Biology](http://globalchange.berkeley.edu/). The repository provides access to over 3 million specimens from various Berkeley natural history museums. These data span more than a century and provide access to georeferenced specimens, species checklists, photographs, vegetation surveys and resurveys and a variety of measurements from environmental sensors located at reserves across University of California's natural reserve system.

3. [iNaturalist][inat]
iNaturalist provides access to crowd sourced citizen science data on species observations.

4. [VertNet][vertnet] (via `rvertnet`)
Similar to `rgbif`, ecoengine, and `rbison` (see below), VertNet provides access to more than 80 million vertebrate records spanning a large number of institutions and museums primarly covering four major disciplines (mammology, herpetology, ornithology, and icthyology). __Note that we don't currenlty support VertNet data in this package, but we should soon__

5. [Biodiversity Information Serving Our Nation][bison] (via `rbison`)
Built by the US Geological Survey's core science analytic team, BISON is a portal that provides access to species occurrence data from several participating institutions.

6. [eBird][ebird] (via `rebird`)
ebird is a database developed and maintained by the Cornell Lab of Ornithology and the National Audubon Society. It provides real-time access to checklist data, data on bird abundance and distribution, and communtiy reports from birders.

7. [AntWeb][antweb] (via `AntWeb`)
AntWeb is the world's largest online database of images, specimen records, and natural history information on ants. It is community driven and open to contribution from anyone with specimen records, natural history comments, or images.

8. [iDigBio][idigbio] (via `ridigbio`)
iDigBio facilitates the digitization of biological and paleobiological specimens and their associated data, and houses specimen data, as well as providing their specimen data via RESTful web services.

9. [OBIS][obis]
OBIS (Ocean Biogeographic Information System) allows users to search marine species datasets from all of the world's oceans.

10. [Atlas of Living Australia][ala]
ALA (Atlas of Living Australia) contains information on all the known species in Australia aggregated from a wide range of data providers: museums, herbaria, community groups, government departments, individuals and universities; it contains more than 50 million occurrence records.

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
#> Occurrences - Found: 617,957, Returned: 100
#> Search type: Scientific
#>   gbif: Accipiter striatus (100)
```

Just gbif data


```r
out$gbif
#> Species [Accipiter striatus (100)] 
#> First 10 rows of [Accipiter_striatus]
#> 
#> # A tibble: 100 × 63
#>                  name  longitude latitude  prov         issues        key
#>                 <chr>      <dbl>    <dbl> <chr>          <chr>      <int>
#> 1  Accipiter striatus  -97.12924 32.70085  gbif cdround,gass84 1453324136
#> 2  Accipiter striatus  -84.74625 40.01773  gbif cdround,gass84 1453369124
#> 3  Accipiter striatus  -72.58904 43.85320  gbif cdround,gass84 1453335509
#> 4  Accipiter striatus  -96.77096 33.22315  gbif cdround,gass84 1453335637
...
```

## Pass options to each data source

Get fine-grained detail over each data source by passing on parameters to the packge rebird in this example.


```r
(out <- occ(query = 'Setophaga caerulescens', from = 'ebird', ebirdopts = list(region = 'US')))
#> Searched: ebird
#> Occurrences - Found: 0, Returned: 199
#> Search type: Scientific
#>   ebird: Setophaga caerulescens (199)
```

Just ebird data


```r
out$ebird
#> Species [Setophaga caerulescens (199)] 
#> First 10 rows of [Setophaga_caerulescens]
#> 
#> # A tibble: 199 × 12
#>                      name longitude latitude  prov
#>                     <chr>     <dbl>    <dbl> <chr>
#> 1  Setophaga caerulescens -81.74960 24.57340 ebird
#> 2  Setophaga caerulescens -82.50378 27.31897 ebird
#> 3  Setophaga caerulescens -82.81150 27.83556 ebird
#> 4  Setophaga caerulescens -93.94818 29.69841 ebird
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
#>                     name   longitude  latitude  prov       date        key
#>                    <chr>       <chr>     <chr> <chr>     <date>      <chr>
#> 1 Setophaga caerulescens -122.673863 45.476817  gbif 2017-01-09 1453379582
#> 2 Setophaga caerulescens  -83.035698 35.431075  gbif 2016-04-25 1453190650
#> 3 Setophaga caerulescens  -83.162943 41.615537  gbif 2016-05-12 1269558094
#> 4 Setophaga caerulescens  -74.405661 40.058324  gbif 2016-05-20 1453340127
#> 5 Setophaga caerulescens  -83.449402 44.252577  gbif 2016-05-14 1291104360
#> 6 Setophaga caerulescens  -83.449517 44.253819  gbif 2016-05-07 1291149600
#> # A tibble: 6 × 6
#>                     name   longitude   latitude  prov       date      key
#>                    <chr>       <chr>      <chr> <chr>     <date>    <chr>
#> 1 Setophaga caerulescens -82.8282344 27.8851167 ebird 2017-04-18 L3547190
#> 2 Setophaga caerulescens   -82.64435  27.532639 ebird 2017-04-18  L189003
#> 3 Setophaga caerulescens -81.7713915 26.1084774 ebird 2017-04-18 L2603780
#> 4 Setophaga caerulescens -84.8486335  29.671734 ebird 2017-04-18  L352112
#> 5 Setophaga caerulescens -80.7833333 33.7833333 ebird 2017-04-18  L109521
#> 6 Setophaga caerulescens -81.9212021  26.746724 ebird 2017-04-17 L3579621
```

## Clean data

All data cleaning functionality is in a new package [scrubr](https://github.com/ropenscilabs/scrubr). [On CRAN](https://cran.r-project.org/package=scrubr).

## Make maps

All mapping functionality is now in a separate package [mapr](https://github.com/ropensci/mapr) (formerly known as `spoccutils`), to make `spocc` easier to maintain. [On CRAN](https://cran.r-project.org/package=mapr).

## Meta

* Please [report any issues or bugs](https://github.com/ropensci/spocc/issues).
* License: MIT
* Get citation information for `spocc` in R doing `citation(package = 'spocc')`
* Please note that this project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.

[![ropensci_footer](https://ropensci.org/public_images/github_footer.png)](https://ropensci.org)

[gbif]: https://github.com/ropensci/rgbif
[vertnet]: https://github.com/ropensci/rvertnet
[bison]: https://github.com/ropensci/rbison
[inat]: https://github.com/ropensci/rinat
[taxize]: https://github.com/ropensci/taxize
[ecoengine]: https://github.com/ropensci/ecoengine
[antweb]: http://antweb.org/
[idigbio]: https://www.idigbio.org/
[obis]: http://www.iobis.org/
[ebird]: http://ebird.org/content/ebird/
[ala]: http://www.ala.org.au/
