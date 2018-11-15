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
#> Occurrences - Found: 737,289, Returned: 100
#> Search type: Scientific
#>   gbif: Accipiter striatus (100)
```

Just gbif data


```r
out$gbif
#> Species [Accipiter striatus (100)] 
#> First 10 rows of [Accipiter_striatus]
#> 
#> # A tibble: 100 x 87
#>    name  longitude latitude prov  issues    key datasetKey publishingOrgKey
#>    <chr>     <dbl>    <dbl> <chr> <chr>   <int> <chr>      <chr>           
#>  1 Acci…    -104.      20.7 gbif  cdrou… 1.81e9 50c9509d-… 28eb1a3f-1c15-4…
#>  2 Acci…     -98.6     33.8 gbif  cdrou… 1.81e9 50c9509d-… 28eb1a3f-1c15-4…
#>  3 Acci…     -74.1     40.1 gbif  cdrou… 1.81e9 50c9509d-… 28eb1a3f-1c15-4…
#>  4 Acci…    -122.      38.0 gbif  cdrou… 1.80e9 50c9509d-… 28eb1a3f-1c15-4…
...
```

## Pass options to each data source

Get fine-grained detail over each data source by passing on parameters to the packge rebird in this example.


```r
(out <- occ(query = 'Setophaga caerulescens', from = 'gbif', gbifopts = list(country = 'US')))
#> Searched: gbif
#> Occurrences - Found: 239,219, Returned: 500
#> Search type: Scientific
#>   gbif: Setophaga caerulescens (500)
```

Get just gbif data


```r
out$gbif
#> Species [Setophaga caerulescens (500)] 
#> First 10 rows of [Setophaga_caerulescens]
#> 
#> # A tibble: 500 x 108
#>    name  longitude latitude prov  issues    key datasetKey publishingOrgKey
#>    <chr>     <dbl>    <dbl> <chr> <chr>   <int> <chr>      <chr>           
#>  1 Seto…     -80.3     25.7 gbif  cdrou… 1.81e9 50c9509d-… 28eb1a3f-1c15-4…
#>  2 Seto…     -80.3     25.8 gbif  cdrou… 1.81e9 50c9509d-… 28eb1a3f-1c15-4…
#>  3 Seto…     -81.4     28.6 gbif  cdrou… 1.84e9 50c9509d-… 28eb1a3f-1c15-4…
#>  4 Seto…     -77.3     39.0 gbif  cdrou… 1.84e9 50c9509d-… 28eb1a3f-1c15-4…
#>  5 Seto…     -83.2     41.6 gbif  cdrou… 1.88e9 50c9509d-… 28eb1a3f-1c15-4…
#>  6 Seto…     -74.0     40.8 gbif  cdrou… 1.84e9 50c9509d-… 28eb1a3f-1c15-4…
#>  7 Seto…     -80.8     35.5 gbif  cdrou… 1.85e9 50c9509d-… 28eb1a3f-1c15-4…
#>  8 Seto…     -97.2     26.1 gbif  cdrou… 1.84e9 50c9509d-… 28eb1a3f-1c15-4…
#>  9 Seto…     -80.3     25.8 gbif  cdrou… 1.85e9 50c9509d-… 28eb1a3f-1c15-4…
#> 10 Seto…     -77.1     38.9 gbif  cdrou… 1.84e9 50c9509d-… 28eb1a3f-1c15-4…
#> # ... with 490 more rows, and 100 more variables: networkKeys <list>,
#> #   installationKey <chr>, publishingCountry <chr>, protocol <chr>,
#> #   lastCrawled <chr>, lastParsed <chr>, crawlId <int>,
#> #   basisOfRecord <chr>, taxonKey <int>, kingdomKey <int>,
#> #   phylumKey <int>, classKey <int>, orderKey <int>, familyKey <int>,
#> #   genusKey <int>, acceptedTaxonKey <int>, scientificName <chr>,
#> #   acceptedScientificName <chr>, kingdom <chr>, phylum <chr>,
#> #   order <chr>, family <chr>, genus <chr>, genericName <chr>,
#> #   specificEpithet <chr>, taxonRank <chr>, taxonomicStatus <chr>,
#> #   dateIdentified <chr>, coordinateUncertaintyInMeters <dbl>,
#> #   stateProvince <chr>, year <int>, month <int>, day <int>,
#> #   eventDate <date>, modified <chr>, lastInterpreted <chr>,
#> #   references <chr>, license <chr>, geodeticDatum <chr>, class <chr>,
#> #   countryCode <chr>, country <chr>, rightsHolder <chr>,
#> #   identifier <chr>, verbatimEventDate <chr>, datasetName <chr>,
#> #   verbatimLocality <chr>, gbifID <chr>, collectionCode <chr>,
#> #   occurrenceID <chr>, taxonID <chr>, catalogNumber <chr>,
#> #   recordedBy <chr>, `http://unknown.org/occurrenceDetails` <chr>,
#> #   institutionCode <chr>, rights <chr>, eventTime <chr>,
#> #   occurrenceRemarks <chr>,
#> #   `http://unknown.org/http_//rs.gbif.org/terms/1.0/Multimedia` <chr>,
#> #   identificationID <chr>, informationWithheld <chr>,
#> #   nomenclaturalCode <chr>, locality <chr>, vernacularName <chr>,
#> #   fieldNotes <chr>, verbatimElevation <chr>, behavior <chr>,
#> #   higherClassification <chr>, sex <chr>, lifeStage <chr>,
#> #   establishmentMeans <chr>, infraspecificEpithet <chr>, continent <chr>,
#> #   recordNumber <chr>, higherGeography <chr>, dynamicProperties <chr>,
#> #   endDayOfYear <chr>, georeferenceVerificationStatus <chr>,
#> #   county <chr>, language <chr>, type <chr>, preparations <chr>,
#> #   occurrenceStatus <chr>, startDayOfYear <chr>,
#> #   bibliographicCitation <chr>, accessRights <chr>, institutionID <chr>,
#> #   dataGeneralizations <chr>, organismID <chr>,
#> #   ownerInstitutionCode <chr>, datasetID <chr>, collectionID <chr>,
#> #   habitat <chr>, georeferencedDate <chr>, georeferencedBy <chr>,
#> #   georeferenceProtocol <chr>, otherCatalogNumbers <chr>,
#> #   georeferenceSources <chr>, identificationRemarks <chr>,
#> #   individualCount <int>
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
#>   name                   longitude  latitude  prov  date       key       
#>   <chr>                  <chr>      <chr>     <chr> <date>     <chr>     
#> 1 Setophaga caerulescens -80.347459 25.743763 gbif  2018-01-20 1806338790
#> 2 Setophaga caerulescens -80.342233 25.77536  gbif  2018-01-19 1805421161
#> 3 Setophaga caerulescens -81.355815 28.569623 gbif  2018-03-14 1837766480
#> 4 Setophaga caerulescens -83.192381 41.627135 gbif  2018-04-28 1880571743
#> 5 Setophaga caerulescens -77.254868 39.006651 gbif  2018-04-29 1841263350
#> 6 Setophaga caerulescens -73.965355 40.782865 gbif  2018-04-29 1841260747
#> # A tibble: 6 x 6
#>   name                   longitude   latitude   prov  date       key  
#>   <chr>                  <chr>       <chr>      <chr> <date>     <chr>
#> 1 Setophaga caerulescens -63.4497222 44.5938889 ebird 2018-11-08 <NA> 
#> 2 Setophaga caerulescens -97.22659   49.8759422 ebird 2018-11-07 <NA> 
#> 3 Setophaga caerulescens -97.227492  49.876486  ebird 2018-11-07 <NA> 
#> 4 Setophaga caerulescens -79.3765    43.6799722 ebird 2018-11-06 <NA> 
#> 5 Setophaga caerulescens -79.6037    43.516773  ebird 2018-11-03 <NA> 
#> 6 Setophaga caerulescens -84.3526679 46.5101339 ebird 2018-11-03 <NA>
```

## Clean data

All data cleaning functionality is in a new package [scrubr](https://github.com/ropenscilabs/scrubr). `scrubr` [on CRAN](https://cran.r-project.org/package=scrubr).

## Make maps

All mapping functionality is now in a separate package [mapr](https://github.com/ropensci/mapr) (formerly known as `spoccutils`), to make `spocc` easier to maintain. `mapr` [on CRAN](https://cran.r-project.org/package=mapr).

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
[idigbio]: https://www.idigbio.org/
[obis]: http://www.iobis.org/
[ebird]: http://ebird.org/content/ebird/
[ala]: http://www.ala.org.au/
