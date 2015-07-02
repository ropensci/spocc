<!--
%\VignetteEngine{knitr::knitr}
%\VignetteIndexEntry{Introduction to the spocc package}
%\VignetteEncoding{UTF-8}
-->



Species occurrence data (spocc)
===============================

### Introduction

The rOpenSci projects aims to provide programmatic access to scientific data repositories on the web. A vast majority of the packages in our current suite retrieve some form of biodiversity or taxonomic data. Since several of these datasets have been georeferenced, it provides numerous opportunities for visualizing species distributions, building species distribution maps, and for using it analyses such as species distribution models. In an effort to streamline access to these data, we have developed a package called Spocc, which provides a unified API to all the biodiversity sources that we provide. The obvious advantage is that a user can interact with a common API and not worry about the nuances in syntax that differ between packages. As more data sources come online, users can access even more data without significant changes to their code. However, it is important to note that spocc will never replicate the full functionality that exists within specific packages. Therefore users with a strong interest in one of the specific data sources listed below would benefit from familiarising themselves with the inner working of the appropriate packages.

### Data Sources

`spocc` currently interfaces with six major biodiversity repositories

1. Global Biodiversity Information Facility (`rgbif`)
[GBIF](http://www.gbif.org/) is a government funded open data repository with several partner organizations with the express goal of providing access to data on Earth's biodiversity. The data are made available by a network of member nodes, coordinating information from various participant organizations and government agencies.

2. [Berkeley Ecoengine](http://ecoengine.berkeley.edu/) (`ecoengine`)
The ecoengine is an open API built by the [Berkeley Initiative for Global Change Biology](http://globalchange.berkeley.edu/). The repository provides access to over 3 million specimens from various Berkeley natural history museums. These data span more than a century and provide access to georeferenced specimens, species checklists, photographs, vegetation surveys and resurveys and a variety of measurements from environmental sensors located at reserves across University of California's natural reserve system.

3. __iNaturalist__ (`rinat`)
iNaturalist provides access to crowd sourced citizen science data on species observations.

4. [VertNet](http://vertnet.org/) (`rvertnet`)
Similar to `rgbif`, ecoengine, and `rbison` (see below), VertNet provides access to more than 80 million vertebrate records spanning a large number of institutions and museums primarly covering four major disciplines (mammology, herpetology, ornithology, and icthyology). __Note that we don't currenlty support VertNet data in this package, but we should soon__

5. [Biodiversity Information Serving Our Nation](http://bison.usgs.ornl.gov/) (`rbison`)
Built by the US Geological Survey's core science analytic team, BISON is a portal that provides access to species occurrence data from several participating institutions.

6. [eBird](http://ebird.org/content/ebird/) (`rebird`)
ebird is a database developed and maintained by the Cornell Lab of Ornithology and the National Audubon Society. It provides real-time access to checklist data, data on bird abundance and distribution, and communtiy reports from birders.

7. [AntWeb](http://antweb.org) (`AntWeb`)
AntWeb is the world's largest online database of images, specimen records, and natural history information on ants. It is community driven and open to contribution from anyone with specimen records, natural history comments, or images.

__Note:__ It's important to keep in mind that several data providers interface with many of the above mentioned repositories. This means that occurence data obtained from BISON may be duplicates of data that are also available through GBIF. We do not have a way to resolve these duplicates or overlaps at this time but it is an issue we are hoping to resolve in future versions of the package. See `?spocc_duplicates`, after installation, for more.


### Data retrieval

The most significant function in spocc is the `occ` (short for occurrence) function. `occ` takes a query, often a species name, and searches across all data sources specified in the `from` argument. For example, one can search for all occurrences of [Sharp-shinned Hawks](http://www.allaboutbirds.org/guide/sharp-shinned_hawk/id) (_Accipiter striatus_) from the GBIF database with the following R call.


```r
library('spocc')
(df <- occ(query = 'Accipiter striatus', from = 'gbif'))
```

```
#> Searched: gbif
#> Occurrences - Found: 447,905, Returned: 500
#> Search type: Scientific
#>   gbif: Accipiter striatus (500)
```

The data returned are part of a `S3` class called `occdat`. This class has slots for each of the data sources described above. One can easily switch the source by changing the `from` parameter in the function call above.

Within each data source is the set of species queried. In the above example, we only asked for occurrence data for one species, but we could have asked for any number. Let's say we asked for data for two species: _Accipiter striatus_, and _Pinus contorta_. Then the structure of the response would be

```
response -- |
            | -- gbif ------- |
                              | -- Accipiter_striatus
                              | -- Pinus_contorta

            | -- ecoengine -- |
                              | -- Accipiter_striatus
                              | -- Pinus_contorta

            | -- inat ------- |
                              | -- Accipiter_striatus
                              | -- Pinus_contorta

            | -- bison ------ |
                              | -- Accipiter_striatus
                              | -- Pinus_contorta

            | -- ebird ------ |
                              | -- Accipiter_striatus
                              | -- Pinus_contorta

            | -- antweb ----- |
                              | -- Accipiter_striatus
                              | -- Pinus_contorta

```

If you only request data from gbif, like `from = 'gbif'`, then the other four source slots are present in the response object, but have no data.

You can quickly get just the GBIF data by indexing to it, like


```r
df$gbif
```

```
#> Species [Accipiter striatus (500)] 
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

When you get data from multiple providers, the fields returned are slightly different, e.g.:


```r
df <- occ(query = 'Accipiter striatus', from = c('gbif', 'ecoengine'), limit = 25)
head(df$gbif$data$Accipiter_striatus)[1:6,1:10]
```

```
#>                 name  longitude latitude                        issues
#> 1 Accipiter striatus    0.00000  0.00000 cucdmis,gass84,mdatunl,zerocd
#> 2 Accipiter striatus         NA       NA                              
#> 3 Accipiter striatus -104.88120 21.46585           cdround,cudc,gass84
#> 4 Accipiter striatus  -71.19554 42.31845           cdround,cudc,gass84
#> 5 Accipiter striatus  -78.15051 37.95521           cdround,cudc,gass84
#> 6 Accipiter striatus  -97.80459 30.41678           cdround,cudc,gass84
#>   prov        key                           datasetKey
#> 1 gbif 1064538129 84b26828-f762-11e1-a439-00145eb45e9a
#> 2 gbif 1065586305 50c9509d-22c7-4a22-a47d-8c48425ef4a7
#> 3 gbif 1065595128 50c9509d-22c7-4a22-a47d-8c48425ef4a7
#> 4 gbif 1065595652 50c9509d-22c7-4a22-a47d-8c48425ef4a7
#> 5 gbif 1065595954 50c9509d-22c7-4a22-a47d-8c48425ef4a7
#> 6 gbif 1065597283 50c9509d-22c7-4a22-a47d-8c48425ef4a7
#>                       publishingOrgKey publishingCountry    protocol
#> 1 8a471700-4ce8-11db-b80e-b8a03c50a862                US DWC_ARCHIVE
#> 2 28eb1a3f-1c15-4a95-931a-4af90ecb574d                US DWC_ARCHIVE
#> 3 28eb1a3f-1c15-4a95-931a-4af90ecb574d                US DWC_ARCHIVE
#> 4 28eb1a3f-1c15-4a95-931a-4af90ecb574d                US DWC_ARCHIVE
#> 5 28eb1a3f-1c15-4a95-931a-4af90ecb574d                US DWC_ARCHIVE
#> 6 28eb1a3f-1c15-4a95-931a-4af90ecb574d                US DWC_ARCHIVE
```

```r
head(df$ecoengine$data$Accipiter_striatus)
```

```
#>   longitude latitude    type state_province
#> 1 -109.7992 32.00118 Feature        Arizona
#> 2 -116.9462 39.24549 Feature         Nevada
#> 3 -122.9879 40.18138 Feature     California
#> 4 -123.4863 39.68622 Feature     California
#> 5 -120.7907 40.67084 Feature     California
#> 6 -116.8950 34.18388 Feature     California
#>   coordinate_uncertainty_in_meters
#> 1                               14
#> 2                            28993
#> 3                             5795
#> 4                             1609
#> 5                             1126
#> 6                             4197
#>                                    recorded_by begin_date   end_date
#> 1              Collector(s): Wilfred H. Osgood 1895-04-22 1895-04-22
#> 2                Collector(s): Chester C. Lamb 1931-09-03 1931-09-03
#> 3             Collector(s): Dawson A. Feathers 1938-08-17 1938-08-17
#> 4  Collector(s): Harry S. Swarth, F. C. Clarke 1916-11-22 1916-11-22
#> 5 Collector(s): Joseph S. Dixon, Leo K. Wilson 1923-10-26 1923-10-26
#> 6               Collector(s): Walter P. Taylor 1907-08-23 1907-08-23
#>                                          source
#> 1 https://ecoengine.berkeley.edu/api/sources/1/
#> 2 https://ecoengine.berkeley.edu/api/sources/1/
#> 3 https://ecoengine.berkeley.edu/api/sources/1/
#> 4 https://ecoengine.berkeley.edu/api/sources/1/
#> 5 https://ecoengine.berkeley.edu/api/sources/1/
#> 6 https://ecoengine.berkeley.edu/api/sources/1/
#>                                                                   url
#> 1 https://ecoengine.berkeley.edu/api/observations/MVZ%3ABird%3A32225/
#> 2 https://ecoengine.berkeley.edu/api/observations/MVZ%3ABird%3A58515/
#> 3 https://ecoengine.berkeley.edu/api/observations/MVZ%3ABird%3A88636/
#> 4 https://ecoengine.berkeley.edu/api/observations/MVZ%3ABird%3A27137/
#> 5 https://ecoengine.berkeley.edu/api/observations/MVZ%3ABird%3A44371/
#> 6 https://ecoengine.berkeley.edu/api/observations/MVZ%3ABird%3A12218/
#>         country                     name
#> 1 United States Accipiter striatus velox
#> 2 United States Accipiter striatus velox
#> 3 United States Accipiter striatus velox
#> 4 United States Accipiter striatus velox
#> 5 United States Accipiter striatus velox
#> 6 United States Accipiter striatus velox
#>                               locality            key
#> 1                          Sulphur Sp. MVZ:Bird:32225
#> 2                          Birch Creek MVZ:Bird:58515
#> 3            1 mi SW N Yolla Bolly Mt. MVZ:Bird:88636
#> 4                          Laytonville MVZ:Bird:27137
#> 5       Spalding's, W shore Eagle Lake MVZ:Bird:44371
#> 6 San Bernardino Mts., Santa Ana River MVZ:Bird:12218
#>                                     remote_resource last_modified
#> 1 http://arctos.database.museum/guid/MVZ:Bird:32225    2015-01-08
#> 2 http://arctos.database.museum/guid/MVZ:Bird:58515    2015-01-08
#> 3 http://arctos.database.museum/guid/MVZ:Bird:88636    2015-01-08
#> 4 http://arctos.database.museum/guid/MVZ:Bird:27137    2015-01-08
#> 5 http://arctos.database.museum/guid/MVZ:Bird:44371    2015-01-08
#> 6 http://arctos.database.museum/guid/MVZ:Bird:12218    2015-01-08
#>   observation_type      prov
#> 1         specimen ecoengine
#> 2         specimen ecoengine
#> 3         specimen ecoengine
#> 4         specimen ecoengine
#> 5         specimen ecoengine
#> 6         specimen ecoengine
```

We provide a function `occ2df` that pulls out a few key columns needed for making maps:


```r
head(occ2df(df))
```

```
#>                 name  longitude latitude prov                date
#> 1 Accipiter striatus    0.00000  0.00000 gbif 2014-12-31 23:00:00
#> 2 Accipiter striatus         NA       NA gbif 2015-01-06 23:00:00
#> 3 Accipiter striatus -104.88120 21.46585 gbif 2015-01-20 23:00:00
#> 4 Accipiter striatus  -71.19554 42.31845 gbif 2015-01-22 17:48:59
#> 5 Accipiter striatus  -78.15051 37.95521 gbif 2015-01-23 14:30:00
#> 6 Accipiter striatus  -97.80459 30.41678 gbif 2015-01-25 16:57:47
#>          key
#> 1 1064538129
#> 2 1065586305
#> 3 1065595128
#> 4 1065595652
#> 5 1065595954
#> 6 1065597283
```


### Fix names

One problem you often run in to is that there can be various names for the same taxon in any one source. For example:


```r
df <- occ(query = 'Pinus contorta', from = c('gbif', 'ecoengine'), limit = 50)
head(df$gbif$data$Pinus_contorta)[1:6, 1:5]
```

```
#>             name longitude latitude              issues prov
#> 1 Pinus contorta   16.6639 56.63950  cudc,depunl,gass84 gbif
#> 2 Pinus contorta   11.7866 58.16500  cudc,depunl,gass84 gbif
#> 3 Pinus contorta -110.6941 44.72325 cdround,cudc,gass84 gbif
#> 4 Pinus contorta   17.8489 59.12440  cudc,depunl,gass84 gbif
#> 5 Pinus contorta   14.4853 61.23390  cudc,depunl,gass84 gbif
#> 6 Pinus contorta    9.3902 62.56215      cdround,gass84 gbif
```

```r
head(df$ecoengine$data$Pinus_contorta)[1:6, 1:5]
```

```
#>   longitude latitude    type state_province
#> 1 -123.7373 39.28080 Feature     California
#> 2 -116.8249 34.09920 Feature     California
#> 3 -123.7410 39.26100 Feature     California
#> 4 -120.0206 38.70028 Feature     California
#> 5 -119.9223 39.28980 Feature     California
#> 6 -123.8674 41.79753 Feature     California
#>   coordinate_uncertainty_in_meters
#> 1                              199
#> 2                              850
#> 3                             1500
#> 4                             1000
#> 5                             1538
#> 6                             1000
```

This is fine, but when trying to make a map in which points are colored for each taxon, you can have many colors for a single taxon, where instead one color per taxon is more appropriate. There is a function in `spocc` called `fixnames`, which has a few options in which you can take the shortest names (usually just the plain binomials like _Homo sapiens_), or the original name queried, or a vector of names supplied by the user.


```r
df <- fixnames(df, how = 'shortest')
head(df$gbif$data$Pinus_contorta[,1:2])
```

```
#>             name longitude
#> 1 Pinus contorta   16.6639
#> 2 Pinus contorta   11.7866
#> 3 Pinus contorta -110.6941
#> 4 Pinus contorta   17.8489
#> 5 Pinus contorta   14.4853
#> 6 Pinus contorta    9.3902
```

```r
head(df$ecoengine$data$Pinus_contorta[,1:2])
```

```
#>   longitude latitude
#> 1 -123.7373 39.28080
#> 2 -116.8249 34.09920
#> 3 -123.7410 39.26100
#> 4 -120.0206 38.70028
#> 5 -119.9223 39.28980
#> 6 -123.8674 41.79753
```

```r
df_comb <- occ2df(df)
head(df_comb); tail(df_comb)
```

```
#>             name longitude latitude prov                date        key
#> 1 Pinus contorta   16.6639 56.63950 gbif 2015-01-03 23:00:00 1051515518
#> 2 Pinus contorta   11.7866 58.16500 gbif 2015-01-17 23:00:00 1052933649
#> 3 Pinus contorta -110.6941 44.72325 gbif 2015-01-01 23:00:00 1088897277
#> 4 Pinus contorta   17.8489 59.12440 gbif 2015-02-14 23:00:00 1058422905
#> 5 Pinus contorta   14.4853 61.23390 gbif 2015-02-15 23:00:00 1065763672
#> 6 Pinus contorta    9.3902 62.56215 gbif 2015-02-19 23:00:00 1092518647
```

```
#>               name longitude latitude      prov       date            key
#> 95  Pinus contorta -120.8269 38.68556 ecoengine 2009-11-05      HSC101346
#> 96  Pinus contorta -120.2051 39.23370 ecoengine 1897-06-25          UC172
#> 97  Pinus contorta -119.9144 38.67000 ecoengine 1989-07-12       CDA18712
#> 98  Pinus contorta -117.8147 34.34022 ecoengine 2012-06-11      RSA811339
#> 99  Pinus contorta -124.1532 41.13350 ecoengine 1957-09-03      RSA175259
#> 100 Pinus contorta -122.4379 41.30890 ecoengine 1956-09-05 CAS:BOT:408911
```

### Visualization routines

All mapping functionality is now in a separate package [spoccutils](https://github.com/ropensci/spoccutils), to make `spocc` easier to maintain. 
