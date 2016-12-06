spocc
========



[![Build Status](https://api.travis-ci.org/ropensci/spocc.png)](https://travis-ci.org/ropensci/spocc)
[![Build status](https://ci.appveyor.com/api/projects/status/lrscgpxs0n925t83?svg=true)](https://ci.appveyor.com/project/sckott/spocc)
[![codecov.io](https://codecov.io/github/ropensci/spocc/coverage.svg?branch=master)](https://codecov.io/github/ropensci/spocc?branch=master)
[![rstudio mirror downloads](http://cranlogs.r-pkg.org/badges/spocc?color=FAB657)](https://github.com/metacran/cranlogs.app)
[![cran version](http://www.r-pkg.org/badges/version/spocc)](https://cran.r-project.org/package=spocc)


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
#> Occurrences - Found: 617,192, Returned: 100
#> Search type: Scientific
#>   gbif: Accipiter striatus (100)
```

Just gbif data


```r
out$gbif
#> Species [Accipiter striatus (100)] 
#> First 10 rows of [Accipiter_striatus]
#> 
#> # A tibble: 100 × 97
#>                  name  longitude latitude  prov                 issues
#>                 <chr>      <dbl>    <dbl> <chr>                  <chr>
#> 1  Accipiter striatus -106.31531 31.71593  gbif         cdround,gass84
#> 2  Accipiter striatus  -97.81493 26.03150  gbif cdround,cucdmis,gass84
#> 3  Accipiter striatus  -81.85267 28.81852  gbif                 gass84
#> 4  Accipiter striatus  -81.85329 28.81806  gbif         cdround,gass84
...
```

## Pass options to each data source

Get fine-grained detail over each data source by passing on parameters to the packge rebird in this example.


```r
(out <- occ(query = 'Setophaga caerulescens', from = 'ebird', ebirdopts = list(region = 'US')))
#> Searched: ebird
#> Occurrences - Found: 0, Returned: 19
#> Search type: Scientific
#>   ebird: Setophaga caerulescens (19)
```

Just ebird data


```r
out$ebird
#> Species [Setophaga caerulescens (19)] 
#> First 10 rows of [Setophaga_caerulescens]
#> 
#> # A tibble: 19 × 12
#>                      name longitude latitude  prov
#>                     <chr>     <dbl>    <dbl> <chr>
#> 1  Setophaga caerulescens -70.30958 43.67663 ebird
#> 2  Setophaga caerulescens -80.22349 26.11165 ebird
#> 3  Setophaga caerulescens -80.37937 25.75437 ebird
#> 4  Setophaga caerulescens -80.59637 24.94986 ebird
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
#> 1 Setophaga caerulescens -83.44952 44.25382  gbif 2016-05-07 1291149600
#> 2 Setophaga caerulescens -83.44952 44.25382  gbif 2016-05-07 1291149586
#> 3 Setophaga caerulescens -83.16294 41.61554  gbif 2016-05-12 1269558094
#> 4 Setophaga caerulescens  -80.0972 42.16493  gbif 2016-05-07 1269546812
#> 5 Setophaga caerulescens    -72.52 43.62952  gbif 2016-05-21 1269574255
#> 6 Setophaga caerulescens -71.14216 42.37114  gbif 2016-05-12 1269554454
#> # A tibble: 6 × 6
#>                     name   longitude   latitude  prov       date      key
#>                    <chr>       <chr>      <chr> <chr>     <date>    <chr>
#> 1 Setophaga caerulescens -91.0964843 30.3108869 ebird 2016-11-26 L3254433
#> 2 Setophaga caerulescens -80.3733989 25.6767589 ebird 2016-11-25 L3379090
#> 3 Setophaga caerulescens -80.2770996 26.0697361 ebird 2016-11-25  L631602
#> 4 Setophaga caerulescens -74.0071169 40.7121688 ebird 2016-11-24 L5102248
#> 5 Setophaga caerulescens -80.2081604 26.9128593 ebird 2016-11-24 L3068365
#> 6 Setophaga caerulescens  -80.214057 26.2768695 ebird 2016-11-24 L1306908
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
