spocc
========



Linux: [![Build Status](https://api.travis-ci.org/ropensci/spocc.png)](https://travis-ci.org/ropensci/spocc)  
Windows: [![Build status](https://ci.appveyor.com/api/projects/status/3d43armi2oanva2s)](https://ci.appveyor.com/project/karthik/spocc)  

**`spocc` = SPecies OCCurrence data**

At rOpenSci, we have been writing R packages to interact with many sources of species occurrence data, including [GBIF][gbif], [Vertnet][vertnet], [BISON][bison], [iNaturalist][inat], the [Berkeley ecoengine][ecoengine], and [AntWeb][antweb]. `spocc` is an R package to query and collect species occurrence data from many sources. The goal is to wrap functions in other R packages to make a seamless experience across data sources for the user.

The inspiration for this comes from users requesting a more seamless experience across data sources, and from our work on a similar package for taxonomy data ([taxize][taxize]).

__BEWARE:__ In cases where you request data from multiple providers, especially when including GBIF, there could be duplicate records since many providers' data eventually ends up with GBIF. See `?spocc_duplicates`, after installation, for more.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

## Installation

Install `spocc`


```r
install.packages("spocc", dependencies = TRUE)
```

Or the development version


```r
install.packages("devtools")
devtools::install_github("ropensci/spocc")
```


```r
library("spocc")
```

## Get data

Get data from GBIF


```r
(out <- occ(query='Accipiter striatus', from='gbif', limit=100))
#> Summary of results - occurrences found for: 
#>  gbif  : 100 records across 1 species 
#>  bison :  0 records across 1 species 
#>  inat  :  0 records across 1 species 
#>  ebird :  0 records across 1 species 
#>  ecoengine :  0 records across 1 species 
#>  antweb :  0 records across 1 species
```


```r
out$gbif # just gbif data
#> Species [Accipiter striatus (100)] 
#> First 10 rows of [Accipiter_striatus]
#> 
#>                  name  longitude latitude prov                 issues
#> 1  Accipiter striatus  -71.72514 18.26982 gbif    cdround,cudc,gass84
#> 2  Accipiter striatus  -72.52547 43.13234 gbif    cdround,cudc,gass84
#> 3  Accipiter striatus  -97.00035 33.07049 gbif    cdround,cudc,gass84
#> 4  Accipiter striatus  -97.19930 32.86027 gbif    cdround,cudc,gass84
#> 5  Accipiter striatus  -97.65347 30.15791 gbif    cdround,cudc,gass84
#> 6  Accipiter striatus -122.43980 37.48967 gbif    cdround,cudc,gass84
#> 7  Accipiter striatus  -76.37695 42.42883 gbif                cdround
#> 8  Accipiter striatus  -76.33708 42.25353 gbif                cdround
#> 9  Accipiter striatus  -99.84577 20.62069 gbif    cdround,cudc,gass84
#> 10 Accipiter striatus -119.25619 34.23091 gbif cdround,gass84,mdatunl
#> ..                ...        ...      ...  ...                    ...
#> Variables not shown: key (int), datasetKey (chr), publishingOrgKey (chr),
#>      publishingCountry (chr), protocol (chr), lastCrawled (chr),
#>      lastParsed (chr), extensions (chr), basisOfRecord (chr), taxonKey
#>      (int), kingdomKey (int), phylumKey (int), classKey (int), orderKey
#>      (int), familyKey (int), genusKey (int), speciesKey (int),
#>      scientificName (chr), kingdom (chr), phylum (chr), order (chr),
#>      family (chr), genus (chr), species (chr), genericName (chr),
#>      specificEpithet (chr), taxonRank (chr), dateIdentified (chr), year
#>      (int), month (int), day (int), eventDate (chr), modified (chr),
#>      lastInterpreted (chr), references (chr), identifiers (chr), facts
#>      (chr), relations (chr), geodeticDatum (chr), class (chr), countryCode
#>      (chr), country (chr), verbatimEventDate (chr), verbatimLocality
#>      (chr), rights (chr), rightsHolder (chr), occurrenceID (chr),
#>      collectionCode (chr), taxonID (chr), gbifID (chr), occurrenceRemarks
#>      (chr), institutionCode (chr), catalogNumber (chr), datasetName (chr),
#>      recordedBy (chr), occurrenceDetails (chr), identifier (chr),
#>      identificationID (chr), informationWithheld (chr), eventTime (chr),
#>      sex (chr), continent (chr), stateProvince (chr), georeferencedDate
#>      (chr), institutionID (chr), higherGeography (chr), type (chr),
#>      identifiedBy (chr), georeferenceSources (chr),
#>      identificationVerificationStatus (chr), samplingProtocol (chr),
#>      endDayOfYear (chr), otherCatalogNumbers (chr), preparations (chr),
#>      georeferenceVerificationStatus (chr), nomenclaturalCode (chr),
#>      individualID (chr), higherClassification (chr), locationAccordingTo
#>      (chr), previousIdentifications (chr), verbatimCoordinateSystem (chr),
#>      georeferenceProtocol (chr), identificationQualifier (chr),
#>      accessRights (chr), dynamicProperties (chr), county (chr), locality
#>      (chr), language (chr), georeferencedBy (chr), lifeStage (chr),
#>      establishmentMeans (chr), startDayOfYear (chr), occurrenceStatus
#>      (chr), elevation (dbl), elevationAccuracy (dbl), waterBody (chr),
#>      recordNumber (chr), samplingEffort (chr), locationRemarks (chr),
#>      vernacularName (chr)
```

Get fine-grained detail over each data source by passing on parameters to the packge rebird in this example.


```r
out <- occ(query='Setophaga caerulescens', from='ebird', ebirdopts=list(region='US'))
out$ebird # just ebird data
#> Species [Setophaga caerulescens (16)] 
#> First 10 rows of [Setophaga_caerulescens]
#> 
#>                      name longitude latitude  prov
#> 1  Setophaga caerulescens -80.82018 24.81497 ebird
#> 2  Setophaga caerulescens -80.31086 25.73408 ebird
#> 3  Setophaga caerulescens -80.27264 25.68065 ebird
#> 4  Setophaga caerulescens -80.92550 25.14160 ebird
#> 5  Setophaga caerulescens -80.12498 25.81765 ebird
#> 6  Setophaga caerulescens -80.30560 25.62582 ebird
#> 7  Setophaga caerulescens -80.34860 25.55849 ebird
#> 8  Setophaga caerulescens -80.12554 26.38334 ebird
#> 9  Setophaga caerulescens -80.27710 26.06974 ebird
#> 10 Setophaga caerulescens -80.15430 25.94190 ebird
#> ..                    ...       ...      ...   ...
#> Variables not shown: comName (chr), howMany (int), locID (chr), locName
#>      (chr), locationPrivate (lgl), obsDt (chr), obsReviewed (lgl),
#>      obsValid (lgl)
```

Get data from many sources in a single call


```r
ebirdopts = list(region='US'); gbifopts = list(country='US')
out <- occ(query='Setophaga caerulescens', from=c('gbif','bison','inat','ebird'), gbifopts=gbifopts, ebirdopts=ebirdopts, limit=50)
head(occ2df(out)); tail(occ2df(out))
#>                     name longitude latitude prov
#> 1 Setophaga caerulescens -72.46131 44.34088 gbif
#> 2 Setophaga caerulescens -72.96430 44.20737 gbif
#> 3 Setophaga caerulescens -73.11068 44.32922 gbif
#> 4 Setophaga caerulescens -72.93318 43.44171 gbif
#> 5 Setophaga caerulescens -70.92961 42.41968 gbif
#> 6 Setophaga caerulescens -71.14434 42.37231 gbif
#>                       name longitude latitude  prov
#> 161 Setophaga caerulescens -80.16017 26.48675 ebird
#> 162 Setophaga caerulescens -80.32015 25.60671 ebird
#> 163 Setophaga caerulescens -80.47223 25.06672 ebird
#> 164 Setophaga caerulescens -80.16164 25.90072 ebird
#> 165 Setophaga caerulescens -80.16423 25.90170 ebird
#> 166 Setophaga caerulescens -80.37937 25.75437 ebird
```

## Make maps

### Leaflet


```r
spp <- c('Danaus plexippus','Accipiter striatus','Pinus contorta')
dat <- occ(query = spp, from = 'gbif', gbifopts = list(hasCoordinate=TRUE))
data <- occ2df(dat)
mapleaflet(data = data, dest = ".")
```

![leafletmap](http://f.cl.ly/items/3w2Y1E3Z0T2T2z40310K/Screen%20Shot%202014-02-09%20at%2010.38.10%20PM.png)


### Github gist


```r
spp <- c('Danaus plexippus','Accipiter striatus','Pinus contorta')
dat <- occ(query=spp, from='gbif', gbifopts=list(hasCoordinate=TRUE))
dat <- fixnames(dat)
dat <- occ2df(dat)
mapgist(data=dat, color=c("#976AAE","#6B944D","#BD5945"))
```

![gistmap](http://f.cl.ly/items/343l2G0A2J3T0n2t433W/Screen%20Shot%202014-02-09%20at%2010.40.57%20PM.png)


### ggplot2


```r
ecoengine_data <- occ(query = 'Lynx rufus californicus', from = 'ecoengine')
mapggplot(ecoengine_data)
```

![ggplot2map](http://f.cl.ly/items/1U1R0E0G392l2q362V33/Screen%20Shot%202014-02-09%20at%2010.44.59%20PM.png)


### Base R plots


```r
spnames <- c('Accipiter striatus', 'Setophaga caerulescens', 'Spinus tristis')
out <- occ(query=spnames, from='gbif', gbifopts=list(hasCoordinate=TRUE))
plot(out, cex=1, pch=10)
```

![basremap](http://f.cl.ly/items/3O13330W3w3Z0H3u1X0s/Screen%20Shot%202014-02-09%20at%2010.46.25%20PM.png)

## Meta

* Please report any issues or bugs](https://github.com/ropensci/spocc/issues).
* License: MIT
* Get citation information for `spocc` in R doing `citation(package = 'spocc')`

[![ropensci footer](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)

[gbif]: https://github.com/ropensci/rgbif
[vertnet]: https://github.com/ropensci/rvertnet
[bison]: https://github.com/ropensci/rbison
[inat]: https://github.com/ropensci/rinat
[taxize]: https://github.com/ropensci/taxize
[ecoengine]: https://github.com/ropensci/ecoengine
[antweb]: http://antweb.org/
