<!--
%\VignetteEngine{knitr::knitr}
%\VignetteIndexEntry{Introduction to the spocc package}
%\VignetteEncoding{UTF-8}
-->



Species occurrence data (spocc)
===============================

### Introduction

The rOpenSci projects aims to provide programmatic access to scientific data repositories on the web. A vast majority of the packages in our current suite retrieve some form of biodiversity or taxonomic data. Since several of these datasets have been georeferenced, it provides numerous opportunities for visualizing species distributions, building species distribution maps, and for using it analyses such as species distribution models. In an effort to streamline access to these data, we have developed a package called `spocc`, which provides a unified API to all the biodiversity sources that we provide. The obvious advantage is that a user can interact with a common API and not worry about the nuances in syntax that differ between packages. As more data sources come online, users can access even more data without significant changes to their code. However, it is important to note that spocc will never replicate the full functionality that exists within specific packages. Therefore users with a strong interest in one of the specific data sources listed below would benefit from familiarising themselves with the inner working of the appropriate packages.

### Data Sources

`spocc` currently interfaces with eight major biodiversity repositories

1. [Global Biodiversity Information Facility (GBIF)](http://www.gbif.org/) (via `rgbif`)
GBIF is a government funded open data repository with several partner organizations with the express goal of providing access to data on Earth's biodiversity. The data are made available by a network of member nodes, coordinating information from various participant organizations and government agencies.

2. [Berkeley Ecoengine](http://ecoengine.berkeley.edu/) (via `ecoengine`)
The ecoengine is an open API built by the [Berkeley Initiative for Global Change Biology](http://globalchange.berkeley.edu/). The repository provides access to over 3 million specimens from various Berkeley natural history museums. These data span more than a century and provide access to georeferenced specimens, species checklists, photographs, vegetation surveys and resurveys and a variety of measurements from environmental sensors located at reserves across University of California's natural reserve system.

3. [iNaturalist](http://www.inaturalist.org/)
iNaturalist provides access to crowd sourced citizen science data on species observations.

4. [VertNet](http://vertnet.org/) (via `rvertnet`)
Similar to `rgbif`, ecoengine, and `rbison` (see below), VertNet provides access to more than 80 million vertebrate records spanning a large number of institutions and museums primarly covering four major disciplines (mammology, herpetology, ornithology, and icthyology). __Note that we don't currenlty support VertNet data in this package, but we should soon__

5. [Biodiversity Information Serving Our Nation](http://bison.usgs.ornl.gov/) (via `rbison`)
Built by the US Geological Survey's core science analytic team, BISON is a portal that provides access to species occurrence data from several participating institutions.

6. [eBird](http://ebird.org/content/ebird/) (via `rebird`)
ebird is a database developed and maintained by the Cornell Lab of Ornithology and the National Audubon Society. It provides real-time access to checklist data, data on bird abundance and distribution, and communtiy reports from birders.

7. [AntWeb](http://antweb.org) (via `AntWeb`)
AntWeb is the world's largest online database of images, specimen records, and natural history information on ants. It is community driven and open to contribution from anyone with specimen records, natural history comments, or images.

8. [iDigBio](https://www.idigbio.org/) (via `ridigbio`)
iDigBio facilitates the digitization of biological and paleobiological specimens and their associated data, and houses specimen data, as well as providing their specimen data via RESTful web services.

__Important Note:__ It's important to keep in mind that several data providers interface with many of the above mentioned repositories. This means that occurence data obtained from BISON may be duplicates of data that are also available through GBIF. We do not have a way to resolve these duplicates or overlaps at this time but it is an issue we are hoping to resolve in future versions of the package. See `?spocc_duplicates`, after installation, for more.


### Data retrieval

The most significant function in spocc is the `occ` (short for occurrence) function. `occ` takes a query, often a species name, and searches across all data sources specified in the `from` argument. For example, one can search for all occurrences of [Sharp-shinned Hawks](http://www.allaboutbirds.org/guide/sharp-shinned_hawk/id) (_Accipiter striatus_) from the GBIF database with the following R call.


```r
library('spocc')
(df <- occ(query = 'Accipiter striatus', from = 'gbif'))
```

```
#> Searched: gbif
#> Occurrences - Found: 447,930, Returned: 500
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

            ... and so on for each data source

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
#> 2  Accipiter striatus  -71.06930 42.34816 gbif
#> 3  Accipiter striatus  -97.25801 32.89462 gbif
#> 4  Accipiter striatus  -72.54554 41.22175 gbif
#> 5  Accipiter striatus -104.83266 21.47117 gbif
#> 6  Accipiter striatus  -75.17209 40.34000 gbif
#> 7  Accipiter striatus  -78.11608 37.98438 gbif
#> 8  Accipiter striatus  -97.64102 30.55880 gbif
#> 9  Accipiter striatus -135.32701 57.05420 gbif
#> 10 Accipiter striatus -109.95193 23.79093 gbif
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
#>      (chr), country (chr), institutionID (chr), county (chr), language
#>      (chr), gbifID (chr), type (chr), preparations (chr), catalogNumber
#>      (chr), occurrenceStatus (chr), institutionCode (chr), rights (chr),
#>      identifier (chr), verbatimEventDate (chr), higherGeography (chr),
#>      nomenclaturalCode (chr), endDayOfYear (chr), locality (chr),
#>      verbatimLocality (chr), collectionCode (chr), occurrenceID (chr),
#>      disposition (chr), otherCatalogNumbers (chr), startDayOfYear (chr),
#>      occurrenceRemarks (chr), accessRights (chr), higherClassification
#>      (chr), dateIdentified (chr), rightsHolder (chr), informationWithheld
#>      (chr), datasetName (chr), taxonID (chr), recordedBy (chr),
#>      http...unknown.org.occurrenceDetails (chr), eventTime (chr),
#>      identificationID (chr), dynamicProperties (chr),
#>      identificationVerificationStatus (chr), locationAccordingTo (chr),
#>      identifiedBy (chr), georeferencedDate (chr), georeferencedBy (chr),
#>      georeferenceProtocol (chr), georeferenceVerificationStatus (chr),
#>      verbatimCoordinateSystem (chr), individualID (chr),
#>      previousIdentifications (chr), identificationQualifier (chr),
#>      samplingProtocol (chr), georeferenceSources (chr), elevation (dbl),
#>      elevationAccuracy (dbl), lifeStage (chr), waterBody (chr),
#>      recordNumber (chr), samplingEffort (chr), locationRemarks (chr),
#>      scientificNameID (chr), georeferenceRemarks (chr), source (chr),
#>      fieldNotes (chr), infraspecificEpithet (chr), collectionID (chr),
#>      ownerInstitutionCode (chr), datasetID (chr), verbatimElevation (chr),
#>      vernacularName (chr), habitat (chr)
```

When you get data from multiple providers, the fields returned are slightly different, e.g.:


```r
df <- occ(query = 'Accipiter striatus', from = c('gbif', 'ecoengine'), limit = 25)
head(df$gbif$data$Accipiter_striatus)[1:6,1:10]
```

```
#>                 name  longitude latitude                        issues
#> 1 Accipiter striatus    0.00000  0.00000 cucdmis,gass84,mdatunl,zerocd
#> 2 Accipiter striatus  -71.06930 42.34816           cdround,cudc,gass84
#> 3 Accipiter striatus  -97.25801 32.89462           cdround,cudc,gass84
#> 4 Accipiter striatus  -72.54554 41.22175           cdround,cudc,gass84
#> 5 Accipiter striatus -104.83266 21.47117           cdround,cudc,gass84
#> 6 Accipiter striatus  -75.17209 40.34000           cdround,cudc,gass84
#>   prov        key                           datasetKey
#> 1 gbif 1064538129 84b26828-f762-11e1-a439-00145eb45e9a
#> 2 gbif 1065595652 50c9509d-22c7-4a22-a47d-8c48425ef4a7
#> 3 gbif 1052607342 50c9509d-22c7-4a22-a47d-8c48425ef4a7
#> 4 gbif 1065586305 50c9509d-22c7-4a22-a47d-8c48425ef4a7
#> 5 gbif 1065595128 50c9509d-22c7-4a22-a47d-8c48425ef4a7
#> 6 gbif 1065588599 50c9509d-22c7-4a22-a47d-8c48425ef4a7
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
#> 1 -122.1706 37.42894 Feature     California
#> 2 -122.2238 37.46977 Feature     California
#> 3 -122.2238 37.46977 Feature     California
#> 4 -122.2238 37.46977 Feature     California
#> 5 -122.2238 37.46977 Feature     California
#> 6 -122.2238 37.46977 Feature     California
#>   coordinate_uncertainty_in_meters   recorded_by begin_date   end_date
#> 1                             1000 C. J. Pierson 1895-01-25 1895-01-25
#> 2                             1000 C. Littlejohn 1922-11-22 1922-11-22
#> 3                             1000 C. Littlejohn 1892-11-18 1892-11-18
#> 4                             1000 C. Littlejohn 1914-10-11 1914-10-11
#> 5                             1000 C. Littlejohn 1922-11-22 1922-11-22
#> 6                             1000 C. Littlejohn 1922-10-25 1922-10-25
#>                                          source
#> 1 https://ecoengine.berkeley.edu/api/sources/8/
#> 2 https://ecoengine.berkeley.edu/api/sources/8/
#> 3 https://ecoengine.berkeley.edu/api/sources/8/
#> 4 https://ecoengine.berkeley.edu/api/sources/8/
#> 5 https://ecoengine.berkeley.edu/api/sources/8/
#> 6 https://ecoengine.berkeley.edu/api/sources/8/
#>                                                                  url
#> 1 https://ecoengine.berkeley.edu/api/observations/CAS%3AORN%3A73314/
#> 2 https://ecoengine.berkeley.edu/api/observations/CAS%3AORN%3A73315/
#> 3 https://ecoengine.berkeley.edu/api/observations/CAS%3AORN%3A73338/
#> 4 https://ecoengine.berkeley.edu/api/observations/CAS%3AORN%3A73318/
#> 5 https://ecoengine.berkeley.edu/api/observations/CAS%3AORN%3A73319/
#> 6 https://ecoengine.berkeley.edu/api/observations/CAS%3AORN%3A73320/
#>         country                     name            locality           key
#> 1 United States Accipiter striatus velox Stanford University CAS:ORN:73314
#> 2 United States Accipiter striatus velox        Redwood City CAS:ORN:73315
#> 3 United States Accipiter striatus velox        Redwood City CAS:ORN:73338
#> 4 United States Accipiter striatus velox        Redwood City CAS:ORN:73318
#> 5 United States Accipiter striatus velox        Redwood City CAS:ORN:73319
#> 6 United States Accipiter striatus velox        Redwood City CAS:ORN:73320
#>   remote_resource last_modified observation_type      prov
#> 1                    2014-06-02         specimen ecoengine
#> 2                    2014-06-02         specimen ecoengine
#> 3                    2014-06-02         specimen ecoengine
#> 4                    2014-06-02         specimen ecoengine
#> 5                    2014-06-02         specimen ecoengine
#> 6                    2014-06-02         specimen ecoengine
```

We provide a function `occ2df` that pulls out a few key columns needed for making maps:


```r
head(occ2df(df))
```

```
#>                 name  longitude latitude prov                date
#> 1 Accipiter striatus    0.00000  0.00000 gbif 2014-12-31 23:00:00
#> 2 Accipiter striatus  -71.06930 42.34816 gbif 2015-01-22 17:48:59
#> 3 Accipiter striatus  -97.25801 32.89462 gbif 2015-01-05 23:00:00
#> 4 Accipiter striatus  -72.54554 41.22175 gbif 2015-01-06 23:00:00
#> 5 Accipiter striatus -104.83266 21.47117 gbif 2015-01-20 23:00:00
#> 6 Accipiter striatus  -75.17209 40.34000 gbif 2015-01-11 20:50:25
#>          key
#> 1 1064538129
#> 2 1065595652
#> 3 1052607342
#> 4 1065586305
#> 5 1065595128
#> 6 1065588599
```


### Fix names

One problem you often run in to is that there can be various names for the same taxon in any one source. For example:


```r
df <- occ(query = 'Pinus contorta', from = c('gbif', 'ecoengine'), limit = 50)
head(df$gbif$data$Pinus_contorta)[1:6, 1:5]
```

```
#>             name  longitude latitude              issues prov
#> 1 Pinus contorta   11.78660 58.16500  cudc,depunl,gass84 gbif
#> 2 Pinus contorta -110.69412 44.72325 cdround,cudc,gass84 gbif
#> 3 Pinus contorta   16.66390 56.63950  cudc,depunl,gass84 gbif
#> 4 Pinus contorta   17.84890 59.12440  cudc,depunl,gass84 gbif
#> 5 Pinus contorta    9.38997 62.56203      cdround,gass84 gbif
#> 6 Pinus contorta    9.39000 62.56203      cdround,gass84 gbif
```

```r
head(df$ecoengine$data$Pinus_contorta)[1:6, 1:5]
```

```
#>   longitude latitude    type state_province
#> 1 -120.6080 39.61928 Feature     California
#> 2 -117.5978 34.24155 Feature     California
#> 3 -117.6086 34.23254 Feature     California
#> 4 -119.4270 38.00443 Feature     California
#> 5 -119.4896 38.01118 Feature     California
#> 6 -119.6049 38.05735 Feature     California
#>   coordinate_uncertainty_in_meters
#> 1                             1000
#> 2                             1000
#> 3                             1000
#> 4                             1000
#> 5                             1000
#> 6                             1000
```

This is fine, but when trying to make a map in which points are colored for each taxon, you can have many colors for a single taxon, where instead one color per taxon is more appropriate. There is a function in `spocc` called `fixnames`, which has a few options in which you can take the shortest names (usually just the plain binomials like _Homo sapiens_), or the original name queried, or a vector of names supplied by the user.


```r
df <- fixnames(df, how = 'shortest')
head(df$gbif$data$Pinus_contorta[,1:2])
```

```
#>             name  longitude
#> 1 Pinus contorta   11.78660
#> 2 Pinus contorta -110.69412
#> 3 Pinus contorta   16.66390
#> 4 Pinus contorta   17.84890
#> 5 Pinus contorta    9.38997
#> 6 Pinus contorta    9.39000
```

```r
head(df$ecoengine$data$Pinus_contorta[,1:2])
```

```
#>   longitude latitude
#> 1 -120.6080 39.61928
#> 2 -117.5978 34.24155
#> 3 -117.6086 34.23254
#> 4 -119.4270 38.00443
#> 5 -119.4896 38.01118
#> 6 -119.6049 38.05735
```

```r
df_comb <- occ2df(df)
head(df_comb); tail(df_comb)
```

```
#>             name  longitude latitude prov                date        key
#> 1 Pinus contorta   11.78660 58.16500 gbif 2015-01-17 23:00:00 1052933649
#> 2 Pinus contorta -110.69412 44.72325 gbif 2015-01-01 23:00:00 1088897277
#> 3 Pinus contorta   16.66390 56.63950 gbif 2015-01-03 23:00:00 1051515518
#> 4 Pinus contorta   17.84890 59.12440 gbif 2015-02-14 23:00:00 1058422905
#> 5 Pinus contorta    9.38997 62.56203 gbif 2015-02-19 23:00:00 1092518927
#> 6 Pinus contorta    9.39000 62.56203 gbif 2015-02-19 23:00:00 1092518920
```

```
#>               name longitude latitude      prov       date
#> 95  Pinus contorta -119.4536 37.59285 ecoengine 1935-08-08
#> 96  Pinus contorta -120.9033 38.62829 ecoengine 1934-10-11
#> 97  Pinus contorta -119.9077 38.63392 ecoengine 1934-10-11
#> 98  Pinus contorta -119.9077 38.63392 ecoengine 1934-10-11
#> 99  Pinus contorta -119.9077 38.63392 ecoengine 1934-10-11
#> 100 Pinus contorta -119.9043 38.60915 ecoengine 1934-10-11
#>                                 key
#> 95  CalPhotos:5555+5555+0000+1419:2
#> 96  CalPhotos:5555+5555+0000+1719:2
#> 97  CalPhotos:5555+5555+0000+1721:4
#> 98  CalPhotos:5555+5555+0000+1722:2
#> 99  CalPhotos:5555+5555+0000+1723:2
#> 100 CalPhotos:5555+5555+0000+1724:3
```

### Visualization routines

All mapping functionality is now in a separate package [spoccutils](https://github.com/ropensci/spoccutils), to make `spocc` easier to maintain.
