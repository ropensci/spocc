

# spocc (SPecies OCCurrence) <img src="man/figures/logo.png" align="right" alt="" width="120">

[![R-check](http://github.com/ropensci/spocc/workflows/R-check/badge.svg)](http://github.com/ropensci/spocc/actions)
[![test-sp-sf](http://github.com/ropensci/spocc/workflows/test-sp-sf/badge.svg)](http://github.com/ropensci/spocc/actions?query=workflow%3Atest-sp-sf)
[![codecov.io](http://codecov.io/github/ropensci/spocc/coverage.svg?branch=master)](http://codecov.io/github/ropensci/spocc?branch=master)
[![cran checks](http://badges.cranchecks.info/worst/spocc.svg)](http://cran.r-project.org/web/checks/check_results_spocc.html)
[![rstudio mirror downloads](http://cranlogs.r-pkg.org/badges/spocc?color=FAB657)](http://github.com/metacran/cranlogs.app)
[![cran version](http://r-pkg.org/badges/version/spocc)](http://cran.r-project.org/package=spocc)

Docs: <http://docs.ropensci.org/spocc/>

At rOpenSci, we have been writing R packages to interact with many sources of species occurrence data, including [GBIF][gbif], [Vertnet][vertnet], [iNaturalist][inat], and [eBird][ebird]. Other databases are out there as well, which we can pull in. `spocc` is an R package to query and collect species occurrence data from many sources. The goal is to to create a seamless search experience across data sources, as well as creating unified outputs across data sources.

`spocc` currently interfaces with seven major biodiversity repositories

1. [Global Biodiversity Information Facility (GBIF)][gbif] (via `rgbif`)
GBIF is a government funded open data repository with several partner organizations with the express goal of providing access to data on Earth's biodiversity. The data are made available by a network of member nodes, coordinating information from various participant organizations and government agencies.

2. [iNaturalist][inat]
iNaturalist provides access to crowd sourced citizen science data on species observations.

3. [VertNet][vertnet] (via `rvertnet`)
Similar to `rgbif` (see below), VertNet provides access to more than 80 million vertebrate records spanning a large number of institutions and museums primarly covering four major disciplines (mammology, herpetology, ornithology, and icthyology).

4. [eBird][ebird] (via `rebird`)
ebird is a database developed and maintained by the Cornell Lab of Ornithology and the National Audubon Society. It provides real-time access to checklist data, data on bird abundance and distribution, and communtiy reports from birders.

5. [iDigBio][idigbio] (via `ridigbio`)
iDigBio facilitates the digitization of biological and paleobiological specimens and their associated data, and houses specimen data, as well as providing their specimen data via RESTful web services.

6. [OBIS][obis]
OBIS (Ocean Biogeographic Information System) allows users to search marine species datasets from all of the world's oceans.

7. [Atlas of Living Australia][ala]
ALA (Atlas of Living Australia) contains information on all the known species in Australia aggregated from a wide range of data providers: museums, herbaria, community groups, government departments, individuals and universities; it contains more than 50 million occurrence records.

The inspiration for this comes from users requesting a more seamless experience across data sources, and from our work on a similar package for taxonomy data ([taxize][taxize]).

__BEWARE:__ In cases where you request data from multiple providers, especially when including GBIF, there could be duplicate records since many providers' data eventually ends up with GBIF. See `?spocc_duplicates`, after installation, for more.

## Learn more

spocc documentation: <docs.ropensci.org/spocc/>

## Contributing

See [CONTRIBUTING.md](http://github.com/ropensci/spocc/blob/master/.github/CONTRIBUTING.md)

## Installation

Stable version from CRAN


```r
install.packages("spocc", dependencies = TRUE)
```

Or the development version from GitHub


```r
install.packages("remotes")
remotes::install_github("ropensci/spocc")
```


```r
library("spocc")
```

## Make maps

All mapping functionality is now in a separate package [mapr](http://github.com/ropensci/mapr) (formerly known as `spoccutils`), to make `spocc` easier to maintain. `mapr` [on CRAN](http://cran.r-project.org/package=mapr).

## Meta

* Please [report any issues or bugs](http://github.com/ropensci/spocc/issues).
* License: MIT
* Get citation information for `spocc` in R doing `citation(package = 'spocc')`
* Please note that this package is released with a [Contributor Code of Conduct](http://ropensci.org/code-of-conduct/). By contributing to this project, you agree to abide by its terms.
* Sticker: Images come from Phylopic <http://phylopic.org/>


[gbif]: http://www.gbif.org/
[vertnet]: http://github.com/ropensci/rvertnet
[inat]: http://www.inaturalist.org/
[taxize]: http://github.com/ropensci/taxize
[idigbio]: http://www.idigbio.org/
[obis]: http://obis.org/
[ebird]: http://ebird.org/home
[ala]: http://www.ala.org.au/
