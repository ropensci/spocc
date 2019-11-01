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
The ecoengine is an open API built by the [Berkeley Initiative for Global Change Biology](http://globalchange.berkeley.edu/). The repository provides access to over 3 million specimens from various Berkeley natural history museums. These data span more than a century and provide access to georeferenced specimens, species checklists, photographs, vegetation surveys and resurveys and a variety of measurements from environmental sensors located at reserves across University of California's natural reserve system.

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

- spocc documentation: <https://ropensci.github.io/spocc/>
- occurrence manual <https://ropenscilabs.github.io/occurrence-manual/> a book in development on working with occurrence data in R

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
#> Occurrences - Found: 963,561, Returned: 100
#> Search type: Scientific
#>   gbif: Accipiter striatus (100)
```

Just gbif data


```r
out$gbif
#> Species [Accipiter striatus (100)] 
#> First 10 rows of [Accipiter_striatus]
#> 
#> # A tibble: 100 x 72
#>    name  longitude latitude prov  issues key   scientificName datasetKey
#>    <chr>     <dbl>    <dbl> <chr> <chr>  <chr> <chr>          <chr>     
#>  1 Acci…    -107.      24.0 gbif  cdrou… 1990… Accipiter str… 50c9509d-…
#>  2 Acci…     -97.3     37.7 gbif  cdrou… 1990… Accipiter str… 50c9509d-…
#>  3 Acci…     -98.4     30.3 gbif  cdrou… 1993… Accipiter str… 50c9509d-…
#>  4 Acci…     -86.6     39.2 gbif  cdrou… 2012… Accipiter str… 50c9509d-…
...
```

## Pass options to each data source

Get fine-grained detail over each data source by passing on parameters to the packge rebird in this example.


```r
(out <- occ(query = 'Setophaga caerulescens', from = 'gbif', gbifopts = list(country = 'US')))
#> Searched: gbif
#> Occurrences - Found: 336,028, Returned: 500
#> Search type: Scientific
#>   gbif: Setophaga caerulescens (500)
```

Get just gbif data


```r
out$gbif
#> Species [Setophaga caerulescens (500)] 
#> First 10 rows of [Setophaga_caerulescens]
#> 
#> # A tibble: 500 x 99
#>    name  longitude latitude prov  issues key   scientificName datasetKey
#>    <chr>     <dbl>    <dbl> <chr> <chr>  <chr> <chr>          <chr>     
#>  1 Seto…     -80.3     25.8 gbif  cdrou… 2006… Setophaga cae… 50c9509d-…
#>  2 Seto…     -80.2     25.4 gbif  gass84 2006… Setophaga cae… 50c9509d-…
#>  3 Seto…     -80.2     25.8 gbif  cdrou… 2013… Setophaga cae… 50c9509d-…
#>  4 Seto…     -80.4     25.2 gbif  cdrou… 2235… Setophaga cae… 50c9509d-…
#>  5 Seto…     -80.3     25.7 gbif  cdrou… 2028… Setophaga cae… 50c9509d-…
#>  6 Seto…     -80.2     25.8 gbif  gass84 2013… Setophaga cae… 50c9509d-…
#>  7 Seto…     -79.1     35.9 gbif  cdrou… 2237… Setophaga cae… 50c9509d-…
#>  8 Seto…     -80.6     28.1 gbif  cdrou… 2238… Setophaga cae… 50c9509d-…
#>  9 Seto…     -80.2     26.5 gbif  cdrou… 2238… Setophaga cae… 50c9509d-…
#> 10 Seto…     -78.5     38.0 gbif  cdrou… 2242… Setophaga cae… 50c9509d-…
#> # … with 490 more rows, and 91 more variables: publishingOrgKey <chr>,
#> #   networkKeys <list>, installationKey <chr>, publishingCountry <chr>,
#> #   protocol <chr>, lastCrawled <chr>, lastParsed <chr>, crawlId <int>,
#> #   basisOfRecord <chr>, taxonKey <int>, kingdomKey <int>,
#> #   phylumKey <int>, classKey <int>, orderKey <int>, familyKey <int>,
#> #   genusKey <int>, speciesKey <int>, acceptedTaxonKey <int>,
#> #   acceptedScientificName <chr>, kingdom <chr>, phylum <chr>,
#> #   order <chr>, family <chr>, genus <chr>, species <chr>,
#> #   genericName <chr>, specificEpithet <chr>, taxonRank <chr>,
#> #   taxonomicStatus <chr>, dateIdentified <chr>,
#> #   coordinateUncertaintyInMeters <dbl>, stateProvince <chr>, year <int>,
#> #   month <int>, day <int>, eventDate <date>, modified <chr>,
#> #   lastInterpreted <chr>, references <chr>, license <chr>,
#> #   geodeticDatum <chr>, class <chr>, countryCode <chr>, country <chr>,
#> #   rightsHolder <chr>, identifier <chr>, `http://unknown.org/nick` <chr>,
#> #   verbatimEventDate <chr>, datasetName <chr>, collectionCode <chr>,
#> #   gbifID <chr>, verbatimLocality <chr>, occurrenceID <chr>,
#> #   taxonID <chr>, catalogNumber <chr>, recordedBy <chr>,
#> #   `http://unknown.org/occurrenceDetails` <chr>, institutionCode <chr>,
#> #   rights <chr>, eventTime <chr>, identificationID <chr>,
#> #   occurrenceRemarks <chr>, informationWithheld <chr>, sex <chr>,
#> #   infraspecificEpithet <chr>, continent <chr>, institutionID <chr>,
#> #   county <chr>, language <chr>, type <chr>, preparations <chr>,
#> #   verbatimElevation <chr>, recordNumber <chr>, higherGeography <chr>,
#> #   nomenclaturalCode <chr>, dataGeneralizations <chr>, locality <chr>,
#> #   organismID <chr>, startDayOfYear <chr>, ownerInstitutionCode <chr>,
#> #   datasetID <chr>, accessRights <chr>, collectionID <chr>,
#> #   higherClassification <chr>,
#> #   `http://unknown.org/recordedByOrcid` <chr>, vernacularName <chr>,
#> #   fieldNotes <chr>, behavior <chr>, associatedTaxa <chr>,
#> #   identificationRemarks <chr>, individualCount <int>
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
#>   name                        longitude  latitude prov  date       key     
#>   <chr>                       <chr>      <chr>    <chr> <date>     <chr>   
#> 1 Setophaga caerulescens (J.… -80.268066 25.7576… gbif  2019-02-24 2006085…
#> 2 Setophaga caerulescens (J.… -80.234612 25.3983… gbif  2019-02-16 2006046…
#> 3 Setophaga caerulescens (J.… -80.224234 25.7841… gbif  2019-03-06 2013734…
#> 4 Setophaga caerulescens (J.… -80.356468 25.1917… gbif  2019-03-29 2235488…
#> 5 Setophaga caerulescens (J.… -80.286566 25.7383… gbif  2019-03-14 2028451…
#> 6 Setophaga caerulescens (J.… -80.224159 25.7849… gbif  2019-03-05 2013007…
#> # A tibble: 6 x 6
#>   name                   longitude   latitude   prov  date       key  
#>   <chr>                  <chr>       <chr>      <chr> <date>     <chr>
#> 1 Setophaga caerulescens -76.7719    44.107757  ebird 2019-10-19 <NA> 
#> 2 Setophaga caerulescens -66.1522698 43.7996334 ebird 2019-10-19 <NA> 
#> 3 Setophaga caerulescens -79.3466091 42.8578308 ebird 2019-10-19 <NA> 
#> 4 Setophaga caerulescens -66.6904063 44.6285592 ebird 2019-10-19 <NA> 
#> 5 Setophaga caerulescens -79.3315839 43.6276706 ebird 2019-10-19 <NA> 
#> 6 Setophaga caerulescens -80.3857613 42.5806413 ebird 2019-10-19 <NA>
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
[ebird]: http://ebird.org/content/ebird/
[ala]: http://www.ala.org.au/
[coc]: https://github.com/ropensci/spocc/blob/master/CODE_OF_CONDUCT.md
