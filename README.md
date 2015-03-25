spocc
========



[![Build Status](https://api.travis-ci.org/ropensci/spocc.png)](https://travis-ci.org/ropensci/spocc)
[![Build status](https://ci.appveyor.com/api/projects/status/3d43armi2oanva2s)](https://ci.appveyor.com/project/karthik/spocc)
[![Coverage Status](https://coveralls.io/repos/ropensci/spocc/badge.svg)](https://coveralls.io/r/ropensci/spocc)

**`spocc` = SPecies OCCurrence data**

At rOpenSci, we have been writing R packages to interact with many sources of species occurrence data, including [GBIF][gbif], [Vertnet][vertnet], [BISON][bison], [iNaturalist][inat], the [Berkeley ecoengine][ecoengine], and [AntWeb][antweb]. `spocc` is an R package to query and collect species occurrence data from many sources. The goal is to wrap functions in other R packages to make a seamless experience across data sources for the user.

The inspiration for this comes from users requesting a more seamless experience across data sources, and from our work on a similar package for taxonomy data ([taxize][taxize]).

__BEWARE:__ In cases where you request data from multiple providers, especially when including GBIF, there could be duplicate records since many providers' data eventually ends up with GBIF. See `?spocc_duplicates`, after installation, for more.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

## Installation

Install `rgdal`. Change to the newest version of `rgdal` as needed.

On Mac, if `install.packages("rgdal")` doesn't work, then


```r
install.packages("http://cran.r-project.org/src/contrib/rgdal_0.9-1.tar.gz", 
                 repos = NULL, type="source", configure.args = "--with-gdal-config=/Library/Frameworks/GDAL.framework/Versions/1.10/unix/bin/gdal-config --with-proj-include=/Library/Frameworks/PROJ.framework/unix/include --with-proj-lib=/Library/Frameworks/PROJ.framework/unix/lib")
```

On Windows - should be the same as Mac.

On a linux box

```
sudo apt-get install r-cran-rgdal
```


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
#> Searched: gbif
#> Occurrences - Found: 447,817, Returned: 100
#> Search type: Scientific
#>   gbif: Accipiter striatus (100)
```


```r
out$gbif # just gbif data
#> Species [Accipiter striatus (100)] 
#> First 10 rows of [Accipiter_striatus]
#> 
#>                  name  longitude latitude prov              issues
#> 1  Accipiter striatus  -99.84577 20.62069 gbif cdround,cudc,gass84
#> 2  Accipiter striatus  -76.33708 42.25353 gbif             cdround
#> 3  Accipiter striatus  -97.00035 33.07049 gbif cdround,cudc,gass84
#> 4  Accipiter striatus  -97.65347 30.15791 gbif cdround,cudc,gass84
#> 5  Accipiter striatus  -97.19930 32.86027 gbif cdround,cudc,gass84
#> 6  Accipiter striatus  -71.72514 18.26982 gbif cdround,cudc,gass84
#> 7  Accipiter striatus  -76.37695 42.42883 gbif             cdround
#> 8  Accipiter striatus  -72.52547 43.13234 gbif cdround,cudc,gass84
#> 9  Accipiter striatus -122.43980 37.48967 gbif cdround,cudc,gass84
#> 10 Accipiter striatus -119.25619 34.23091 gbif     cdround,mdatunl
#> ..                ...        ...      ...  ...                 ...
#> Variables not shown: key (int), datasetKey (chr), publishingOrgKey (chr),
#>      publishingCountry (chr), protocol (chr), lastCrawled (chr),
#>      lastParsed (chr), extensions (chr), basisOfRecord (chr), taxonKey
#>      (int), kingdomKey (int), phylumKey (int), classKey (int), orderKey
#>      (int), familyKey (int), genusKey (int), speciesKey (int),
#>      scientificName (chr), kingdom (chr), phylum (chr), order (chr),
#>      family (chr), genus (chr), species (chr), genericName (chr),
#>      specificEpithet (chr), taxonRank (chr), dateIdentified (chr), year
#>      (int), month (int), day (int), eventDate (time), modified (chr),
#>      lastInterpreted (chr), references (chr), identifiers (chr), facts
#>      (chr), relations (chr), geodeticDatum (chr), class (chr), countryCode
#>      (chr), country (chr), verbatimEventDate (chr), informationWithheld
#>      (chr), verbatimLocality (chr), http...unknown.org.occurrenceDetails
#>      (chr), rights (chr), rightsHolder (chr), occurrenceID (chr),
#>      collectionCode (chr), taxonID (chr), gbifID (chr), institutionCode
#>      (chr), catalogNumber (chr), datasetName (chr), recordedBy (chr),
#>      identifier (chr), identificationID (chr), sex (chr), continent (chr),
#>      stateProvince (chr), georeferencedDate (chr), institutionID (chr),
#>      higherGeography (chr), type (chr), identifiedBy (chr),
#>      georeferenceSources (chr), identificationVerificationStatus (chr),
#>      samplingProtocol (chr), endDayOfYear (chr), otherCatalogNumbers
#>      (chr), preparations (chr), georeferenceVerificationStatus (chr),
#>      nomenclaturalCode (chr), individualID (chr), higherClassification
#>      (chr), locationAccordingTo (chr), previousIdentifications (chr),
#>      verbatimCoordinateSystem (chr), georeferenceProtocol (chr),
#>      identificationQualifier (chr), accessRights (chr), dynamicProperties
#>      (chr), county (chr), locality (chr), language (chr), georeferencedBy
#>      (chr), eventTime (chr), occurrenceRemarks (chr), lifeStage (chr),
#>      establishmentMeans (chr), startDayOfYear (chr), occurrenceStatus
#>      (chr), elevation (dbl), elevationAccuracy (dbl), waterBody (chr),
#>      samplingEffort (chr), recordNumber (chr), locationRemarks (chr),
#>      infraspecificEpithet (chr), collectionID (chr), ownerInstitutionCode
#>      (chr), datasetID (chr), verbatimElevation (chr), habitat (chr),
#>      vernacularName (chr)
```

Get fine-grained detail over each data source by passing on parameters to the packge rebird in this example.


```r
out <- occ(query='Setophaga caerulescens', from='ebird', ebirdopts=list(region='US'))
out$ebird # just ebird data
#> Species [Setophaga caerulescens (21)] 
#> First 10 rows of [Setophaga_caerulescens]
#> 
#>                      name longitude latitude  prov
#> 1  Setophaga caerulescens -80.23479 25.76613 ebird
#> 2  Setophaga caerulescens -80.60694 25.38206 ebird
#> 3  Setophaga caerulescens -80.12498 25.81765 ebird
#> 4  Setophaga caerulescens -80.12837 26.95568 ebird
#> 5  Setophaga caerulescens -80.27264 25.68065 ebird
#> 6  Setophaga caerulescens -80.31086 25.73408 ebird
#> 7  Setophaga caerulescens -80.21406 26.27687 ebird
#> 8  Setophaga caerulescens -80.13187 26.10616 ebird
#> 9  Setophaga caerulescens -80.36944 25.17583 ebird
#> 10 Setophaga caerulescens -80.15430 25.94190 ebird
#> ..                    ...       ...      ...   ...
#> Variables not shown: comName (chr), howMany (int), locID (chr), locName
#>      (chr), locationPrivate (lgl), obsDt (time), obsReviewed (lgl),
#>      obsValid (lgl)
```

Get data from many sources in a single call


```r
ebirdopts = list(region='US'); gbifopts = list(country='US')
out <- occ(query='Setophaga caerulescens', from=c('gbif','bison','inat','ebird'), gbifopts=gbifopts, ebirdopts=ebirdopts, limit=50)
head(occ2df(out)); tail(occ2df(out))
#>                     name longitude latitude prov                date
#> 1 Setophaga caerulescens -71.14499 42.37113 gbif 2014-05-11 19:04:00
#> 2 Setophaga caerulescens -77.07004 38.83311 gbif 2014-05-14 19:17:00
#> 3 Setophaga caerulescens -72.93318 43.44171 gbif 2014-05-17 22:00:00
#> 4 Setophaga caerulescens -77.06994 38.83316 gbif 2014-05-08 22:00:00
#> 5 Setophaga caerulescens -73.15174 43.62287 gbif 2014-05-19 22:00:00
#> 6 Setophaga caerulescens -77.07002 38.83317 gbif 2014-05-11 01:19:00
#>         key
#> 1 910496783
#> 2 911496288
#> 3 923913257
#> 4 910495942
#> 5 911495177
#> 6 911496233
#>                       name longitude latitude  prov                date
#> 166 Setophaga caerulescens -80.30560 25.62582 ebird 2015-03-17 07:20:00
#> 167 Setophaga caerulescens -80.34860 25.55849 ebird 2015-03-15 16:30:00
#> 168 Setophaga caerulescens -80.16423 25.90170 ebird 2015-03-15 10:45:00
#> 169 Setophaga caerulescens -80.06920 26.38290 ebird 2015-03-15 07:05:00
#> 170 Setophaga caerulescens -80.92550 25.14160 ebird 2015-03-12 11:30:00
#> 171 Setophaga caerulescens -81.81060 24.54630 ebird 2015-03-11 15:00:00
#>          key
#> 166  L779318
#> 167  L466835
#> 168 L1109964
#> 169  L127416
#> 170  L127438
#> 171  L127449
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
