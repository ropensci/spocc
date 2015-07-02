spocc
========



[![Build Status](https://api.travis-ci.org/ropensci/spocc.png)](https://travis-ci.org/ropensci/spocc)
[![Build status](https://ci.appveyor.com/api/projects/status/3d43armi2oanva2s)](https://ci.appveyor.com/project/karthik/spocc)
[![Coverage Status](https://coveralls.io/repos/ropensci/spocc/badge.svg)](https://coveralls.io/r/ropensci/spocc)
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
(out <- occ(query='Accipiter striatus', from='gbif', limit=100))
#> Searched: gbif
#> Occurrences - Found: 447,905, Returned: 100
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
#> 2  Accipiter striatus         NA       NA gbif
#> 3  Accipiter striatus -104.88120 21.46585 gbif
#> 4  Accipiter striatus  -71.19554 42.31845 gbif
#> 5  Accipiter striatus  -78.15051 37.95521 gbif
#> 6  Accipiter striatus  -97.80459 30.41678 gbif
#> 7  Accipiter striatus  -75.17209 40.34000 gbif
#> 8  Accipiter striatus -122.20175 37.88370 gbif
#> 9  Accipiter striatus  -99.47894 27.44924 gbif
#> 10 Accipiter striatus -135.32701 57.05420 gbif
#> ..                ...        ...      ...  ...
#> Variables not shown: issues (chr), key (int), datasetKey (chr),
#>      publishingOrgKey (chr), publishingCountry (chr), protocol (chr),
#>      lastCrawled (chr), lastParsed (chr), extensions (chr), basisOfRecord
#>      (chr), sex (chr), establishmentMeans (chr), taxonKey (int),
#>      kingdomKey (int), phylumKey (int), classKey (int), orderKey (int),
#>      familyKey (int), genusKey (int), speciesKey (int), scientificName
#>      (chr), kingdom (chr), phylum (chr), order (chr), family (chr), genus
#>      (chr), species (chr), genericName (chr), specificEpithet (chr),
#>      taxonRank (chr), continent (chr), stateProvince (chr), year (int),
#>      month (int), day (int), eventDate (time), modified (chr),
#>      lastInterpreted (chr), references (chr), identifiers (chr), facts
#>      (chr), relations (chr), geodeticDatum (chr), class (chr), countryCode
#>      (chr), country (chr), startDayOfYear (chr), verbatimEventDate (chr),
#>      preparations (chr), institutionID (chr), verbatimLocality (chr),
#>      nomenclaturalCode (chr), higherClassification (chr), rights (chr),
#>      higherGeography (chr), occurrenceID (chr), type (chr), collectionCode
#>      (chr), occurrenceRemarks (chr), gbifID (chr), accessRights (chr),
#>      institutionCode (chr), endDayOfYear (chr), county (chr),
#>      catalogNumber (chr), otherCatalogNumbers (chr), occurrenceStatus
#>      (chr), locality (chr), language (chr), identifier (chr), disposition
#>      (chr), dateIdentified (chr), informationWithheld (chr),
#>      http...unknown.org.occurrenceDetails (chr), rightsHolder (chr),
#>      taxonID (chr), datasetName (chr), recordedBy (chr), identificationID
#>      (chr), eventTime (chr), georeferencedDate (chr), georeferenceSources
#>      (chr), identifiedBy (chr), identificationVerificationStatus (chr),
#>      samplingProtocol (chr), georeferenceVerificationStatus (chr),
#>      individualID (chr), locationAccordingTo (chr),
#>      verbatimCoordinateSystem (chr), previousIdentifications (chr),
#>      georeferenceProtocol (chr), identificationQualifier (chr),
#>      dynamicProperties (chr), georeferencedBy (chr), lifeStage (chr),
#>      elevation (dbl), elevationAccuracy (dbl), waterBody (chr),
#>      recordNumber (chr), samplingEffort (chr), locationRemarks (chr),
#>      infraspecificEpithet (chr), collectionID (chr), ownerInstitutionCode
#>      (chr), datasetID (chr), verbatimElevation (chr), vernacularName (chr)
```

## Pas options to each data source

Get fine-grained detail over each data source by passing on parameters to the packge rebird in this example.


```r
out <- occ(query='Setophaga caerulescens', from='ebird', ebirdopts=list(region='US'))
out$ebird # just ebird data
#> Species [Setophaga caerulescens (500)] 
#> First 10 rows of [Setophaga_caerulescens]
#> 
#>                      name longitude latitude  prov
#> 1  Setophaga caerulescens -72.00877 43.44167 ebird
#> 2  Setophaga caerulescens -71.71499 44.82760 ebird
#> 3  Setophaga caerulescens -69.24381 46.10138 ebird
#> 4  Setophaga caerulescens -83.48799 35.02802 ebird
#> 5  Setophaga caerulescens -71.73941 44.76401 ebird
#> 6  Setophaga caerulescens -86.01660 44.75613 ebird
#> 7  Setophaga caerulescens -73.99459 44.30380 ebird
#> 8  Setophaga caerulescens -80.27513 38.19799 ebird
#> 9  Setophaga caerulescens -74.03718 42.20338 ebird
#> 10 Setophaga caerulescens -73.88611 44.51111 ebird
#> ..                    ...       ...      ...   ...
#> Variables not shown: comName (chr), howMany (dbl), locID (chr), locName
#>      (chr), locationPrivate (lgl), obsDt (time), obsReviewed (lgl),
#>      obsValid (lgl)
```

## Many data sources at once

Get data from many sources in a single call


```r
ebirdopts = list(region='US'); gbifopts = list(country='US')
out <- occ(query='Setophaga caerulescens', from=c('gbif','bison','inat','ebird'), gbifopts=gbifopts, ebirdopts=ebirdopts, limit=50)
head(occ2df(out)); tail(occ2df(out))
#> Error in mapply(FUN = f, ..., SIMPLIFY = FALSE): object 'id' not found
#> Error in mapply(FUN = f, ..., SIMPLIFY = FALSE): object 'id' not found
```

## Make maps

All mapping functionality is now in a separate package [spoccutils](https://github.com/ropensci/spoccutils), to make `spocc` easier to maintain.

## Meta

* Please [report any issues or bugs](https://github.com/ropensci/spocc/issues).
* License: MIT
* Get citation information for `spocc` in R doing `citation(package = 'spocc')`

[![ropensci_footer](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)

[gbif]: https://github.com/ropensci/rgbif
[vertnet]: https://github.com/ropensci/rvertnet
[bison]: https://github.com/ropensci/rbison
[inat]: https://github.com/ropensci/rinat
[taxize]: https://github.com/ropensci/taxize
[ecoengine]: https://github.com/ropensci/ecoengine
[antweb]: http://antweb.org/
