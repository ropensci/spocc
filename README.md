spocc
========



[![Build Status](https://travis-ci.org/ropensci/spocc.svg?branch=master)](https://travis-ci.org/ropensci/spocc)
[![Build status](https://ci.appveyor.com/api/projects/status/lrscgpxs0n925t83?svg=true)](https://ci.appveyor.com/project/sckott/spocc)
[![codecov.io](https://codecov.io/github/ropensci/spocc/coverage.svg?branch=master)](https://codecov.io/github/ropensci/spocc?branch=master)
[![cran checks](https://cranchecks.info/badges/worst/spocc)](https://cranchecks.info/pkgs/spocc)
[![rstudio mirror downloads](https://cranlogs.r-pkg.org/badges/spocc?color=FAB657)](https://github.com/metacran/cranlogs.app)
[![cran version](https://www.r-pkg.org/badges/version/spocc)](https://cran.r-project.org/package=spocc)


**`spocc` = SPecies OCCurrence data**

At rOpenSci, we have been writing R packages to interact with many sources of species occurrence data, including [GBIF][gbif], [Vertnet][vertnet], [BISON][bison], [iNaturalist][inat], the [Berkeley ecoengine][ecoengine], and [eBird][ebird]. Other databases are out there as well, which we can pull in. `spocc` is an R package to query and collect species occurrence data from many sources. The goal is to to create a seamless search experience across data sources, as well as creating unified outputs across data sources.

`spocc` currently interfaces with nine major biodiversity repositories

1. [Global Biodiversity Information Facility (GBIF)][gbif] (via `rgbif`)
GBIF is a government funded open data repository with several partner organizations with the express goal of providing access to data on Earth's biodiversity. The data are made available by a network of member nodes, coordinating information from various participant organizations and government agencies.

2. [Berkeley Ecoengine][ecoengine] (via `ecoengine`)
The ecoengine is an open API built by the [Berkeley Initiative for Global Change Biology](https://globalchange.berkeley.edu/). The repository provides access to over 3 million specimens from various Berkeley natural history museums. These data span more than a century and provide access to georeferenced specimens, species checklists, photographs, vegetation surveys and resurveys and a variety of measurements from environmental sensors located at reserves across University of California's natural reserve system.

3. [iNaturalist][inat]
iNaturalist provides access to crowd sourced citizen science data on species observations.

4. [VertNet][vertnet] (via `rvertnet`)
Similar to `rgbif`, ecoengine, and `rbison` (see below), VertNet provides access to more than 80 million vertebrate records spanning a large number of institutions and museums primarly covering four major disciplines (mammology, herpetology, ornithology, and icthyology). __Note that we don't currenlty support VertNet data in this package, but we should soon__

5. [Biodiversity Information Serving Our Nation][bison] (via `rbison`)
Built by the US Geological Survey's core science analytic team, BISON is a portal that provides access to species occurrence data from several participating institutions.

6. [eBird][ebird] (via `rebird`)
ebird is a database developed and maintained by the Cornell Lab of Ornithology and the National Audubon Society. It provides real-time access to checklist data, data on bird abundance and distribution, and communtiy reports from birders.

7. [iDigBio][idigbio] (via `ridigbio`)
iDigBio facilitates the digitization of biological and paleobiological specimens and their associated data, and houses specimen data, as well as providing their specimen data via RESTful web services.

8. [OBIS][obis]
OBIS (Ocean Biogeographic Information System) allows users to search marine species datasets from all of the world's oceans.

9. [Atlas of Living Australia][ala]
ALA (Atlas of Living Australia) contains information on all the known species in Australia aggregated from a wide range of data providers: museums, herbaria, community groups, government departments, individuals and universities; it contains more than 50 million occurrence records.

The inspiration for this comes from users requesting a more seamless experience across data sources, and from our work on a similar package for taxonomy data ([taxize][taxize]).

__BEWARE:__ In cases where you request data from multiple providers, especially when including GBIF, there could be duplicate records since many providers' data eventually ends up with GBIF. See `?spocc_duplicates`, after installation, for more.

## Learn more

- spocc documentation: <https://docs.ropensci.org/spocc/>
- occurrence manual <https://books.ropensci.org/occurrences/> a book in development on working with occurrence data in R

## Contributing

See [CONTRIBUTING.md](https://github.com/ropensci/spocc/blob/master/.github/CONTRIBUTING.md)

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
#> Occurrences - Found: 964,225, Returned: 100
#> Search type: Scientific
#>   gbif: Accipiter striatus (100)
```

Just gbif data


```r
out$gbif
#> Species [Accipiter striatus (100)] 
#> First 10 rows of [Accipiter_striatus]
#> 
#> # A tibble: 100 x 73
#>    name  longitude latitude prov  issues key   scientificName datasetKey
#>    <chr>     <dbl>    <dbl> <chr> <chr>  <chr> <chr>          <chr>     
#>  1 Acci…    -107.      35.1 gbif  cdrou… 2542… Accipiter str… 50c9509d-…
#>  2 Acci…     -90.0     37.1 gbif  cdrou… 2543… Accipiter str… 50c9509d-…
#>  3 Acci…     -99.3     36.5 gbif  cdrou… 2543… Accipiter str… 50c9509d-…
#>  4 Acci…     -76.0     39.6 gbif  cdrou… 2543… Accipiter str… 50c9509d-…
...
```

## Pass options to each data source

Get fine-grained detail over each data source by passing on parameters to the packge rebird in this example.


```r
(out <- occ(query = 'Setophaga caerulescens', from = 'gbif', gbifopts = list(country = 'US')))
#> Searched: gbif
#> Occurrences - Found: 336,904, Returned: 500
#> Search type: Scientific
#>   gbif: Setophaga caerulescens (500)
```

Get just gbif data


```r
out$gbif
#> Species [Setophaga caerulescens (500)] 
#> First 10 rows of [Setophaga_caerulescens]
#> 
#> # A tibble: 500 x 98
#>    name  longitude latitude prov  issues key   scientificName datasetKey
#>    <chr>     <dbl>    <dbl> <chr> <chr>  <chr> <chr>          <chr>     
#>  1 Seto…     -96.7     32.9 gbif  cdrou… 2550… Setophaga cae… 50c9509d-…
#>  2 Seto…     -96.7     32.9 gbif  gass84 2557… Setophaga cae… 50c9509d-…
#>  3 Seto…     -96.7     32.9 gbif  gass84 2563… Setophaga cae… 50c9509d-…
#>  4 Seto…     -96.6     33.0 gbif  cdrou… 2563… Setophaga cae… 50c9509d-…
#>  5 Seto…     -96.7     32.9 gbif  cdrou… 2563… Setophaga cae… 50c9509d-…
#>  6 Seto…     -80.2     25.4 gbif  gass84 2006… Setophaga cae… 50c9509d-…
#>  7 Seto…     -80.3     25.8 gbif  cdrou… 2006… Setophaga cae… 50c9509d-…
#>  8 Seto…     -80.2     25.8 gbif  gass84 2013… Setophaga cae… 50c9509d-…
#>  9 Seto…     -80.2     25.8 gbif  cdrou… 2013… Setophaga cae… 50c9509d-…
#> 10 Seto…     -80.3     25.7 gbif  cdrou… 2028… Setophaga cae… 50c9509d-…
#> # … with 490 more rows, and 90 more variables: publishingOrgKey <chr>,
#> #   installationKey <chr>, publishingCountry <chr>, protocol <chr>,
#> #   lastCrawled <chr>, lastParsed <chr>, crawlId <int>, basisOfRecord <chr>,
#> #   taxonKey <int>, kingdomKey <int>, phylumKey <int>, classKey <int>,
#> #   orderKey <int>, familyKey <int>, genusKey <int>, speciesKey <int>,
#> #   acceptedTaxonKey <int>, acceptedScientificName <chr>, kingdom <chr>,
#> #   phylum <chr>, order <chr>, family <chr>, genus <chr>, species <chr>,
#> #   genericName <chr>, specificEpithet <chr>, taxonRank <chr>,
#> #   taxonomicStatus <chr>, dateIdentified <chr>, stateProvince <chr>,
#> #   year <int>, month <int>, day <int>, eventDate <date>, modified <chr>,
#> #   lastInterpreted <chr>, references <chr>, license <chr>,
#> #   geodeticDatum <chr>, class <chr>, countryCode <chr>, country <chr>,
#> #   rightsHolder <chr>, identifier <chr>, `http://unknown.org/nick` <chr>,
#> #   verbatimEventDate <chr>, datasetName <chr>, gbifID <chr>,
#> #   collectionCode <chr>, verbatimLocality <chr>, occurrenceID <chr>,
#> #   taxonID <chr>, catalogNumber <chr>, recordedBy <chr>,
#> #   `http://unknown.org/occurrenceDetails` <chr>, institutionCode <chr>,
#> #   rights <chr>, eventTime <chr>, identificationID <chr>,
#> #   coordinateUncertaintyInMeters <dbl>, occurrenceRemarks <chr>,
#> #   informationWithheld <chr>, `http://unknown.org/recordedByOrcid` <chr>,
#> #   sex <chr>, infraspecificEpithet <chr>, continent <chr>,
#> #   institutionID <chr>, county <chr>, language <chr>, type <chr>,
#> #   preparations <chr>, verbatimElevation <chr>, recordNumber <chr>,
#> #   higherGeography <chr>, nomenclaturalCode <chr>, dataGeneralizations <chr>,
#> #   locality <chr>, organismID <chr>, startDayOfYear <chr>,
#> #   ownerInstitutionCode <chr>, datasetID <chr>, accessRights <chr>,
#> #   higherClassification <chr>, collectionID <chr>,
#> #   identificationRemarks <chr>, vernacularName <chr>, fieldNotes <chr>,
#> #   behavior <chr>, associatedTaxa <chr>, individualCount <int>
```

## Many data sources at once

Get data from many sources in a single call


```r
ebirdopts <- list(loc = 'CA') # search in Canada only
gbifopts <- list(country = 'US') # search in United States only
out <- occ(query = 'Setophaga caerulescens', from = c('gbif','bison','inat','ebird'), 
  gbifopts = gbifopts, ebirdopts = ebirdopts, limit = 50)
dat <- occ2df(out)
head(dat); tail(dat)
#> # A tibble: 6 x 6
#>   name                            longitude  latitude  prov  date       key     
#>   <chr>                           <chr>      <chr>     <chr> <date>     <chr>   
#> 1 Setophaga caerulescens (J.F.Gm… -96.745132 32.886913 gbif  2020-01-06 2550022…
#> 2 Setophaga caerulescens (J.F.Gm… -96.745205 32.886382 gbif  2020-01-14 2557796…
#> 3 Setophaga caerulescens (J.F.Gm… -96.745267 32.886457 gbif  2020-01-18 2563510…
#> 4 Setophaga caerulescens (J.F.Gm… -96.630926 32.986361 gbif  2020-01-18 2563520…
#> 5 Setophaga caerulescens (J.F.Gm… -96.745338 32.886095 gbif  2020-01-20 2563537…
#> 6 Setophaga caerulescens (J.F.Gm… -80.234612 25.398317 gbif  2019-02-16 2006046…
#> # A tibble: 6 x 6
#>   name                   longitude      latitude      prov  date       key     
#>   <chr>                  <chr>          <chr>         <chr> <date>     <chr>   
#> 1 Setophaga caerulescens -96.745155     32.88639167   inat  2020-01-08 37403962
#> 2 Setophaga caerulescens -96.7451324463 32.8869132996 inat  2020-01-06 37375771
#> 3 Setophaga caerulescens -70.7911467253 42.7337687735 inat  2017-05-17 37349924
#> 4 Setophaga caerulescens -77.8893836543 24.797648184  inat  2019-12-26 37346047
#> 5 Setophaga caerulescens -77.8905785744 24.7979890688 inat  2019-12-26 37346036
#> 6 Setophaga caerulescens -90.8332658    47.5830972    inat  2011-09-03 37331776
```

## Clean data

All data cleaning functionality is in a new package [scrubr](https://github.com/ropenscilabs/scrubr). `scrubr` [on CRAN](https://cran.r-project.org/package=scrubr).

## Make maps

All mapping functionality is now in a separate package [mapr](https://github.com/ropensci/mapr) (formerly known as `spoccutils`), to make `spocc` easier to maintain. `mapr` [on CRAN](https://cran.r-project.org/package=mapr).

## Meta

* Please [report any issues or bugs](https://github.com/ropensci/spocc/issues).
* License: MIT
* Get citation information for `spocc` in R doing `citation(package = 'spocc')`
* Please note that this project is released with a [Contributor Code of Conduct][coc].
By participating in this project you agree to abide by its terms.

[![ropensci_footer](https://ropensci.org/public_images/github_footer.png)](https://ropensci.org)

[gbif]: https://github.com/ropensci/rgbif
[vertnet]: https://github.com/ropensci/rvertnet
[bison]: https://github.com/ropensci/rbison
[inat]: https://github.com/ropensci/rinat
[taxize]: https://github.com/ropensci/taxize
[ecoengine]: https://github.com/ropensci/ecoengine
[idigbio]: https://www.idigbio.org/
[obis]: http://www.iobis.org/
[ebird]: https://ebird.org/home
[ala]: https://www.ala.org.au/
[coc]: https://github.com/ropensci/spocc/blob/master/CODE_OF_CONDUCT.md
