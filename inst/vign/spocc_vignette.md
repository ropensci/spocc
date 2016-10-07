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
#> Occurrences - Found: 528,936, Returned: 500
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
#> # A tibble: 500 × 115
#>                  name  longitude latitude  prov         issues        key
#>                 <chr>      <dbl>    <dbl> <chr>          <chr>      <int>
#> 1  Accipiter striatus  -97.94314 30.04580  gbif cdround,gass84 1233600470
#> 2  Accipiter striatus  -77.05161 38.87834  gbif cdround,gass84 1270044795
#> 3  Accipiter striatus  -95.50117 29.76086  gbif cdround,gass84 1229610478
#> 4  Accipiter striatus  -96.74874 33.03102  gbif cdround,gass84 1257416040
#> 5  Accipiter striatus  -75.65139 45.44557  gbif cdround,gass84 1227768502
#> 6  Accipiter striatus -103.01232 36.38905  gbif cdround,gass84 1227771246
#> 7  Accipiter striatus  -96.55633 17.88640  gbif cdround,gass84 1272110730
#> 8  Accipiter striatus  -72.48018 43.72704  gbif cdround,gass84 1233600875
#> 9  Accipiter striatus -116.67145 32.94147  gbif cdround,gass84 1229613664
#> 10 Accipiter striatus -123.44703 48.54571  gbif cdround,gass84 1249281491
#> # ... with 490 more rows, and 109 more variables: datasetKey <chr>,
#> #   publishingOrgKey <chr>, publishingCountry <chr>, protocol <chr>,
#> #   lastCrawled <chr>, lastParsed <chr>, crawlId <int>,
#> #   basisOfRecord <chr>, taxonKey <int>, kingdomKey <int>,
#> #   phylumKey <int>, classKey <int>, orderKey <int>, familyKey <int>,
#> #   genusKey <int>, scientificName <chr>, kingdom <chr>, phylum <chr>,
#> #   order <chr>, family <chr>, genus <chr>, genericName <chr>,
#> #   specificEpithet <chr>, taxonRank <chr>, dateIdentified <chr>,
#> #   coordinateUncertaintyInMeters <dbl>, year <int>, month <int>,
#> #   day <int>, eventDate <date>, modified <chr>, lastInterpreted <chr>,
#> #   references <chr>, license <chr>, geodeticDatum <chr>, class <chr>,
#> #   countryCode <chr>, country <chr>, rightsHolder <chr>,
#> #   identifier <chr>, informationWithheld <chr>, verbatimEventDate <chr>,
#> #   datasetName <chr>, collectionCode <chr>, verbatimLocality <chr>,
#> #   gbifID <chr>, occurrenceID <chr>, taxonID <chr>, catalogNumber <chr>,
#> #   recordedBy <chr>, `http://unknown.org/occurrenceDetails` <chr>,
#> #   institutionCode <chr>, rights <chr>, eventTime <chr>,
#> #   identificationID <chr>, occurrenceRemarks <chr>,
#> #   individualCount <int>, sex <chr>, elevation <dbl>,
#> #   elevationAccuracy <dbl>, continent <chr>, stateProvince <chr>,
#> #   institutionID <chr>, dynamicProperties <chr>, county <chr>,
#> #   identificationVerificationStatus <chr>, language <chr>, type <chr>,
#> #   locationAccordingTo <chr>, preparations <chr>, identifiedBy <chr>,
#> #   georeferencedDate <chr>, higherGeography <chr>,
#> #   nomenclaturalCode <chr>, georeferencedBy <chr>,
#> #   georeferenceProtocol <chr>, endDayOfYear <chr>,
#> #   georeferenceVerificationStatus <chr>, verbatimCoordinateSystem <chr>,
#> #   locality <chr>, otherCatalogNumbers <chr>, organismID <chr>,
#> #   previousIdentifications <chr>, identificationQualifier <chr>,
#> #   samplingProtocol <chr>, accessRights <chr>,
#> #   higherClassification <chr>, georeferenceSources <chr>,
#> #   lifeStage <chr>, vernacularName <chr>, reproductiveCondition <chr>,
#> #   establishmentMeans <chr>, occurrenceStatus <chr>, disposition <chr>,
#> #   startDayOfYear <chr>, infraspecificEpithet <chr>,
#> #   georeferenceRemarks <chr>, collectionID <chr>, recordNumber <chr>,
#> #   habitat <chr>, ...
```

When you get data from multiple providers, the fields returned are slightly different, e.g.:


```r
df <- occ(query = 'Accipiter striatus', from = c('gbif', 'ecoengine'), limit = 25)
df$gbif$data$Accipiter_striatus
```

```
#> # A tibble: 25 × 62
#>                  name  longitude latitude         issues  prov        key
#>                 <chr>      <dbl>    <dbl>          <chr> <chr>      <int>
#> 1  Accipiter striatus  -97.94314 30.04580 cdround,gass84  gbif 1233600470
#> 2  Accipiter striatus  -77.05161 38.87834 cdround,gass84  gbif 1270044795
#> 3  Accipiter striatus  -95.50117 29.76086 cdround,gass84  gbif 1229610478
#> 4  Accipiter striatus  -96.74874 33.03102 cdround,gass84  gbif 1257416040
#> 5  Accipiter striatus  -75.65139 45.44557 cdround,gass84  gbif 1227768502
#> 6  Accipiter striatus -103.01232 36.38905 cdround,gass84  gbif 1227771246
#> 7  Accipiter striatus  -96.55633 17.88640 cdround,gass84  gbif 1272110730
#> 8  Accipiter striatus  -72.48018 43.72704 cdround,gass84  gbif 1233600875
#> 9  Accipiter striatus -116.67145 32.94147 cdround,gass84  gbif 1229613664
#> 10 Accipiter striatus -123.44703 48.54571 cdround,gass84  gbif 1249281491
#> # ... with 15 more rows, and 56 more variables: datasetKey <chr>,
#> #   publishingOrgKey <chr>, publishingCountry <chr>, protocol <chr>,
#> #   lastCrawled <chr>, lastParsed <chr>, crawlId <int>,
#> #   basisOfRecord <chr>, taxonKey <int>, kingdomKey <int>,
#> #   phylumKey <int>, classKey <int>, orderKey <int>, familyKey <int>,
#> #   genusKey <int>, scientificName <chr>, kingdom <chr>, phylum <chr>,
#> #   order <chr>, family <chr>, genus <chr>, genericName <chr>,
#> #   specificEpithet <chr>, taxonRank <chr>, dateIdentified <chr>,
#> #   coordinateUncertaintyInMeters <dbl>, year <int>, month <int>,
#> #   day <int>, eventDate <date>, modified <chr>, lastInterpreted <chr>,
#> #   references <chr>, license <chr>, geodeticDatum <chr>, class <chr>,
#> #   countryCode <chr>, country <chr>, rightsHolder <chr>,
#> #   identifier <chr>, informationWithheld <chr>, verbatimEventDate <chr>,
#> #   datasetName <chr>, collectionCode <chr>, verbatimLocality <chr>,
#> #   gbifID <chr>, occurrenceID <chr>, taxonID <chr>, catalogNumber <chr>,
#> #   recordedBy <chr>, `http://unknown.org/occurrenceDetails` <chr>,
#> #   institutionCode <chr>, rights <chr>, eventTime <chr>,
#> #   identificationID <chr>, occurrenceRemarks <chr>
```

```r
df$ecoengine$data$Accipiter_striatus
```

```
#> # A tibble: 25 × 17
#>    longitude latitude
#> *      <dbl>    <dbl>
#> 1   -87.5932  41.7945
#> 2   -86.9241  41.2665
#> 3  -118.3016  34.0320
#> 4  -118.3016  34.0320
#> 5  -118.3016  34.0320
#> 6  -118.3016  34.0320
#> 7  -118.4415  34.2677
#> 8  -118.4415  34.2677
#> 9  -118.3016  34.0320
#> 10 -118.3016  34.0320
#> # ... with 15 more rows, and 15 more variables: url <chr>, key <chr>,
#> #   observation_type <chr>, name <chr>, country <chr>,
#> #   state_province <chr>, begin_date <date>, end_date <chr>, source <chr>,
#> #   remote_resource <chr>, locality <chr>,
#> #   coordinate_uncertainty_in_meters <int>, recorded_by <chr>,
#> #   last_modified <chr>, prov <chr>
```

We provide a function `occ2df` that pulls out a few key columns needed for making maps:


```r
occ2df(df)
```

```
#> # A tibble: 50 × 6
#>                  name  longitude latitude  prov       date        key
#>                 <chr>      <dbl>    <dbl> <chr>     <date>      <chr>
#> 1  Accipiter striatus  -97.94314 30.04580  gbif 2016-01-24 1233600470
#> 2  Accipiter striatus  -77.05161 38.87834  gbif 2016-01-02 1270044795
#> 3  Accipiter striatus  -95.50117 29.76086  gbif 2016-01-09 1229610478
#> 4  Accipiter striatus  -96.74874 33.03102  gbif 2016-01-28 1257416040
#> 5  Accipiter striatus  -75.65139 45.44557  gbif 2016-01-02 1227768502
#> 6  Accipiter striatus -103.01232 36.38905  gbif 2016-01-04 1227771246
#> 7  Accipiter striatus  -96.55633 17.88640  gbif 2016-01-14 1272110730
#> 8  Accipiter striatus  -72.48018 43.72704  gbif 2016-01-17 1233600875
#> 9  Accipiter striatus -116.67145 32.94147  gbif 2016-01-12 1229613664
#> 10 Accipiter striatus -123.44703 48.54571  gbif 2016-01-31 1249281491
#> # ... with 40 more rows
```


### Fix names

One problem you often run in to is that there can be various names for the same taxon in any one source. For example:


```r
df <- occ(query = 'Pinus contorta', from = c('gbif', 'ecoengine'), limit = 50)
df$gbif$data$Pinus_contorta$name
```

```
#>  [1] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#>  [5] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#>  [9] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [13] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [17] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [21] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [25] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [29] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [33] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [37] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [41] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [45] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [49] "Pinus contorta" "Pinus contorta"
```

```r
df$ecoengine$data$Pinus_contorta$name
```

```
#>  [1] "Pinus contorta"                  "Pinus contorta"                 
#>  [3] "Pinus contorta"                  "Pinus contorta"                 
#>  [5] "Pinus contorta"                  "Pinus contorta"                 
#>  [7] "Pinus contorta"                  "Pinus contorta"                 
#>  [9] "Pinus contorta"                  "Pinus contorta"                 
#> [11] "Pinus contorta"                  "Pinus contorta"                 
#> [13] "Pinus contorta"                  "Pinus contorta"                 
#> [15] "Pinus contorta"                  "Pinus contorta"                 
#> [17] "Pinus contorta"                  "Pinus contorta"                 
#> [19] "Pinus contorta subsp. murrayana" "Pinus contorta"                 
#> [21] "Pinus contorta"                  "Pinus contorta"                 
#> [23] "Pinus contorta"                  "Pinus contorta"                 
#> [25] "Pinus contorta"                  "Pinus contorta"                 
#> [27] "Pinus contorta"                  "Pinus contorta"                 
#> [29] "Pinus contorta"                  "Pinus contorta"                 
#> [31] "Pinus contorta subsp. murrayana" "Pinus contorta subsp. murrayana"
#> [33] "Pinus contorta"                  "Pinus contorta subsp. murrayana"
#> [35] "Pinus contorta subsp. murrayana" "Pinus contorta subsp. murrayana"
#> [37] "Pinus contorta"                  "Pinus contorta"                 
#> [39] "Pinus contorta"                  "Pinus contorta"                 
#> [41] "Pinus contorta"                  "Pinus contorta"                 
#> [43] "Pinus contorta"                  "Pinus contorta"                 
#> [45] "Pinus contorta"                  "Pinus contorta"                 
#> [47] "Pinus contorta"                  "Pinus contorta"                 
#> [49] "Pinus contorta"                  "Pinus contorta"
```

This is fine, but when trying to make a map in which points are colored for each taxon, you can have many colors for a single taxon, where instead one color per taxon is more appropriate. There is a function in `spocc` called `fixnames`, which has a few options in which you can take the shortest names (usually just the plain binomials like _Homo sapiens_), or the original name queried, or a vector of names supplied by the user.


```r
df <- fixnames(df, how = 'query')
df$gbif$data$Pinus_contorta$name
```

```
#>  [1] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#>  [5] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#>  [9] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [13] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [17] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [21] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [25] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [29] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [33] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [37] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [41] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [45] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [49] "Pinus contorta" "Pinus contorta"
```

```r
df$ecoengine$data$Pinus_contorta$name
```

```
#>  [1] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#>  [5] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#>  [9] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [13] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [17] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [21] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [25] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [29] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [33] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [37] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [41] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [45] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [49] "Pinus contorta" "Pinus contorta"
```

```r
df_comb <- occ2df(df)
head(df_comb); tail(df_comb)
```

```
#> # A tibble: 6 × 6
#>             name  longitude  latitude  prov       date        key
#>            <chr>      <dbl>     <dbl> <chr>     <date>      <chr>
#> 1 Pinus contorta  168.85006 -44.94818  gbif 2016-01-30 1269541527
#> 2 Pinus contorta -120.33987  39.34308  gbif 2016-01-03 1249276846
#> 3 Pinus contorta  176.32093 -39.33307  gbif 2016-02-16 1249301037
#> 4 Pinus contorta -123.35278  48.90594  gbif 2016-02-29 1253314823
#> 5 Pinus contorta -123.98210  46.20296  gbif 2016-02-07 1249288703
#> 6 Pinus contorta    7.01607  62.86770  gbif 2016-02-20 1272958740
```

```
#> # A tibble: 6 × 6
#>             name longitude latitude      prov   date
#>            <chr>     <dbl>    <dbl>     <chr> <date>
#> 1 Pinus contorta -120.3358  39.1632 ecoengine   <NA>
#> 2 Pinus contorta -119.9564  38.7905 ecoengine   <NA>
#> 3 Pinus contorta -121.2308  40.3064 ecoengine   <NA>
#> 4 Pinus contorta -121.2308  40.3064 ecoengine   <NA>
#> 5 Pinus contorta -119.5066  37.6013 ecoengine   <NA>
#> 6 Pinus contorta -119.5158  37.6024 ecoengine   <NA>
#> # ... with 1 more variables: key <chr>
```

## Clean data

All data cleaning functionality is in a new package [scrubr](https://github.com/ropenscilabs/scrubr). [On CRAN](https://cran.r-project.org/package=scrubr).

## Make maps

All mapping functionality is now in a separate package [mapr](https://github.com/ropensci/mapr) (formerly known as `spoccutils`), to make `spocc` easier to maintain. [On CRAN](https://cran.r-project.org/package=mapr).
