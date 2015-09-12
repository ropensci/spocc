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
(out <- occ(query='Accipiter striatus', from='gbif', limit=100))
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
#> 1  Accipiter striatus  -97.64102 30.55880 gbif
#> 2  Accipiter striatus -104.83266 21.47117 gbif
#> 3  Accipiter striatus  -75.17209 40.34000 gbif
#> 4  Accipiter striatus  -78.11608 37.98438 gbif
#> 5  Accipiter striatus    0.00000  0.00000 gbif
#> 6  Accipiter striatus  -97.25801 32.89462 gbif
#> 7  Accipiter striatus  -72.54554 41.22175 gbif
#> 8  Accipiter striatus  -71.06930 42.34816 gbif
#> 9  Accipiter striatus  -99.47478 27.48211 gbif
#> 10 Accipiter striatus -109.95193 23.79093 gbif
#> ..                ...        ...      ...  ...
#> Variables not shown: issues (chr), key (int), datasetKey (chr),
#>      publishingOrgKey (chr), publishingCountry (chr), protocol (chr),
#>      lastCrawled (chr), lastParsed (chr), extensions (chr), basisOfRecord
#>      (chr), taxonKey (int), kingdomKey (int), phylumKey (int), classKey
#>      (int), orderKey (int), familyKey (int), genusKey (int), speciesKey
#>      (int), scientificName (chr), kingdom (chr), phylum (chr), order
#>      (chr), family (chr), genus (chr), species (chr), genericName (chr),
#>      specificEpithet (chr), taxonRank (chr), dateIdentified (chr), year
#>      (int), month (int), day (int), eventDate (time), modified (chr),
#>      lastInterpreted (chr), references (chr), identifiers (chr), facts
#>      (chr), relations (chr), geodeticDatum (chr), class (chr), countryCode
#>      (chr), country (chr), rightsHolder (chr), identifier (chr),
#>      informationWithheld (chr), verbatimEventDate (chr), datasetName
#>      (chr), collectionCode (chr), verbatimLocality (chr), gbifID (chr),
#>      occurrenceID (chr), taxonID (chr), recordedBy (chr), catalogNumber
#>      (chr), http...unknown.org.occurrenceDetails (chr), institutionCode
#>      (chr), rights (chr), eventTime (chr), identificationID (chr),
#>      occurrenceRemarks (chr), sex (chr), establishmentMeans (chr),
#>      continent (chr), stateProvince (chr), institutionID (chr), county
#>      (chr), language (chr), type (chr), preparations (chr),
#>      occurrenceStatus (chr), higherGeography (chr), nomenclaturalCode
#>      (chr), endDayOfYear (chr), locality (chr), disposition (chr),
#>      otherCatalogNumbers (chr), startDayOfYear (chr), accessRights (chr),
#>      higherClassification (chr), dynamicProperties (chr),
#>      identificationVerificationStatus (chr), locationAccordingTo (chr),
#>      identifiedBy (chr), georeferencedDate (chr), georeferencedBy (chr),
#>      georeferenceProtocol (chr), georeferenceVerificationStatus (chr),
#>      verbatimCoordinateSystem (chr), individualID (chr),
#>      previousIdentifications (chr), identificationQualifier (chr),
#>      samplingProtocol (chr), georeferenceSources (chr), elevation (dbl),
#>      elevationAccuracy (dbl), lifeStage (chr), scientificNameID (chr),
#>      georeferenceRemarks (chr), source (chr), fieldNotes (chr), waterBody
#>      (chr), recordNumber (chr), samplingEffort (chr), locationRemarks
#>      (chr), infraspecificEpithet (chr), collectionID (chr),
#>      ownerInstitutionCode (chr), datasetID (chr), verbatimElevation (chr),
#>      vernacularName (chr)
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
#> 1  Setophaga caerulescens -88.14688 39.46639 ebird
#> 2  Setophaga caerulescens -71.16393 42.65060 ebird
#> 3  Setophaga caerulescens -83.21080 39.90013 ebird
#> 4  Setophaga caerulescens -80.30560 25.62582 ebird
#> 5  Setophaga caerulescens -79.91361 32.74346 ebird
#> 6  Setophaga caerulescens -76.43384 43.31383 ebird
#> 7  Setophaga caerulescens -78.80536 36.06608 ebird
#> 8  Setophaga caerulescens -75.18879 39.86365 ebird
#> 9  Setophaga caerulescens -80.34590 36.81220 ebird
#> 10 Setophaga caerulescens -77.04935 38.95550 ebird
#> ..                    ...       ...      ...   ...
#> Variables not shown: comName (chr), howMany (int), locID (chr), locName
#>      (chr), locationPrivate (lgl), obsDt (time), obsReviewed (lgl),
#>      obsValid (lgl)
```

## Many data sources at once

Get data from many sources in a single call


```r
ebirdopts = list(region='US'); gbifopts = list(country='US')
out <- occ(query='Setophaga caerulescens', from=c('gbif','bison','inat','ebird'), gbifopts=gbifopts, ebirdopts=ebirdopts, limit=50)
head(occ2df(out)); tail(occ2df(out))
#>                     name longitude latitude prov                date
#> 1 Setophaga caerulescens -80.82181 24.81413 gbif 2015-03-26 23:00:00
#> 2 Setophaga caerulescens -82.55674 35.63396 gbif 2015-04-21 18:51:02
#> 3 Setophaga caerulescens -81.69378 36.14885 gbif 2015-05-01 22:00:00
#> 4 Setophaga caerulescens -83.19085 41.62769 gbif 2015-05-16 22:00:00
#> 5 Setophaga caerulescens -82.87321 24.62802 gbif 2015-05-06 22:00:00
#> 6 Setophaga caerulescens -77.07069 38.83192 gbif 2015-05-08 12:09:00
#>          key
#> 1 1088930021
#> 2 1088954620
#> 3 1122965432
#> 4 1092893939
#> 5 1092893709
#> 6 1088980026
#>                       name longitude latitude  prov                date
#> 195 Setophaga caerulescens -78.01059 40.53442 ebird 2015-09-11 06:58:00
#> 196 Setophaga caerulescens -75.39042 40.63633 ebird 2015-09-11 06:55:00
#> 197 Setophaga caerulescens -76.47900 42.46045 ebird 2015-09-11 06:54:00
#> 198 Setophaga caerulescens -77.04298 38.95766 ebird 2015-09-11 06:50:00
#> 199 Setophaga caerulescens -77.05141 38.95940 ebird 2015-09-11 06:45:00
#> 200 Setophaga caerulescens -77.04676 38.96532 ebird 2015-09-11 06:45:00
#>          key
#> 195 L2354489
#> 196  L372101
#> 197  L287796
#> 198  L283552
#> 199  L280792
#> 200  L599606
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
