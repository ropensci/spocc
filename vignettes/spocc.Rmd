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

`spocc` currently interfaces with nine major biodiversity repositories

1. [Global Biodiversity Information Facility (GBIF)](http://www.gbif.org/) (via `rgbif`)
GBIF is a government funded open data repository with several partner organizations with the express goal of providing access to data on Earth's biodiversity. The data are made available by a network of member nodes, coordinating information from various participant organizations and government agencies.

2. [Berkeley Ecoengine](https://ecoengine.berkeley.edu/) (via `ecoengine`)
The ecoengine is an open API built by the [Berkeley Initiative for Global Change Biology](http://globalchange.berkeley.edu/). The repository provides access to over 3 million specimens from various Berkeley natural history museums. These data span more than a century and provide access to georeferenced specimens, species checklists, photographs, vegetation surveys and resurveys and a variety of measurements from environmental sensors located at reserves across University of California's natural reserve system.

3. [iNaturalist](http://www.inaturalist.org/)
iNaturalist provides access to crowd sourced citizen science data on species observations.

4. [VertNet](http://vertnet.org/) (via `rvertnet`)
Similar to `rgbif`, ecoengine, and `rbison` (see below), VertNet provides access to more than 80 million vertebrate records spanning a large number of institutions and museums primarly covering four major disciplines (mammology, herpetology, ornithology, and icthyology). __Note that we don't currenlty support VertNet data in this package, but we should soon__

5. Biodiversity Information Serving Our Nation (https://bison.usgs.gov/) (via `rbison`)
Built by the US Geological Survey's core science analytic team, BISON is a portal that provides access to species occurrence data from several participating institutions.

6. [eBird](http://ebird.org/content/ebird/) (via `rebird`)
ebird is a database developed and maintained by the Cornell Lab of Ornithology and the National Audubon Society. It provides real-time access to checklist data, data on bird abundance and distribution, and communtiy reports from birders.

7. [iDigBio](https://www.idigbio.org/) (via `ridigbio`)
iDigBio facilitates the digitization of biological and paleobiological specimens and their associated data, and houses specimen data, as well as providing their specimen data via RESTful web services.

8. [OBIS](http://www.iobis.org/)
OBIS (Ocean Biogeographic Information System) allows users to search marine species datasets from all of the world's oceans.

9. [Atlas of Living Australia](http://www.ala.org.au/)
ALA (Atlas of Living Australia) contains information on all the known species in Australia aggregated from a wide range of data providers: museums, herbaria, community groups, government departments, individuals and universities; it contains more than 50 million occurrence records.

__Important Note:__ It's important to keep in mind that several data providers interface with many of the above mentioned repositories. This means that occurence data obtained from BISON may be duplicates of data that are also available through GBIF. We do not have a way to resolve these duplicates or overlaps at this time but it is an issue we are hoping to resolve in future versions of the package. See `?spocc_duplicates`, after installation, for more.


### Data retrieval

The most significant function in spocc is the `occ` (short for occurrence) function. `occ` takes a query, often a species name, and searches across all data sources specified in the `from` argument. For example, one can search for all occurrences of [Sharp-shinned Hawks](https://www.allaboutbirds.org/guide/sharp-shinned_hawk/id) (_Accipiter striatus_) from the GBIF database with the following R call.


```r
library('spocc')
(df <- occ(query = 'Accipiter striatus', from = 'gbif'))
```

```
#> Searched: gbif
#> Occurrences - Found: 964,225, Returned: 500
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
#> # A tibble: 500 x 113
#>    name  longitude latitude prov  issues key   scientificName datasetKey publishingOrgKey installationKey publishingCount… protocol lastCrawled lastParsed crawlId basisOfRecord
#>    <chr>     <dbl>    <dbl> <chr> <chr>  <chr> <chr>          <chr>      <chr>            <chr>           <chr>            <chr>    <chr>       <chr>        <int> <chr>        
#>  1 Acci…    -107.      35.1 gbif  cdrou… 2542… Accipiter str… 50c9509d-… 28eb1a3f-1c15-4… 997448a8-f762-… US               DWC_ARC… 2020-02-06… 2020-02-0…     199 HUMAN_OBSERV…
#>  2 Acci…     -90.0     37.1 gbif  cdrou… 2543… Accipiter str… 50c9509d-… 28eb1a3f-1c15-4… 997448a8-f762-… US               DWC_ARC… 2020-02-06… 2020-02-0…     199 HUMAN_OBSERV…
#>  3 Acci…     -99.3     36.5 gbif  cdrou… 2543… Accipiter str… 50c9509d-… 28eb1a3f-1c15-4… 997448a8-f762-… US               DWC_ARC… 2020-02-06… 2020-02-0…     199 HUMAN_OBSERV…
#>  4 Acci…     -76.0     39.6 gbif  cdrou… 2543… Accipiter str… 50c9509d-… 28eb1a3f-1c15-4… 997448a8-f762-… US               DWC_ARC… 2020-02-06… 2020-02-0…     199 HUMAN_OBSERV…
#>  5 Acci…     -73.5     40.7 gbif  gass84 2543… Accipiter str… 50c9509d-… 28eb1a3f-1c15-4… 997448a8-f762-… US               DWC_ARC… 2020-02-06… 2020-02-0…     199 HUMAN_OBSERV…
#>  6 Acci…    -118.      34.6 gbif  cdrou… 2549… Accipiter str… 50c9509d-… 28eb1a3f-1c15-4… 997448a8-f762-… US               DWC_ARC… 2020-02-06… 2020-02-0…     199 HUMAN_OBSERV…
#>  7 Acci…    -121.      36.6 gbif  cdrou… 2550… Accipiter str… 50c9509d-… 28eb1a3f-1c15-4… 997448a8-f762-… US               DWC_ARC… 2020-02-06… 2020-02-0…     199 HUMAN_OBSERV…
#>  8 Acci…     -97.3     27.6 gbif  cdrou… 2550… Accipiter str… 50c9509d-… 28eb1a3f-1c15-4… 997448a8-f762-… US               DWC_ARC… 2020-02-06… 2020-02-0…     199 HUMAN_OBSERV…
#>  9 Acci…     -88.9     30.5 gbif  cdrou… 2550… Accipiter str… 50c9509d-… 28eb1a3f-1c15-4… 997448a8-f762-… US               DWC_ARC… 2020-02-06… 2020-02-0…     199 HUMAN_OBSERV…
#> 10 Acci…     -96.9     33.1 gbif  cdrou… 2550… Accipiter str… 50c9509d-… 28eb1a3f-1c15-4… 997448a8-f762-… US               DWC_ARC… 2020-02-06… 2020-02-0…     199 HUMAN_OBSERV…
#> # … with 490 more rows, and 97 more variables: taxonKey <int>, kingdomKey <int>, phylumKey <int>, classKey <int>, orderKey <int>, familyKey <int>, genusKey <int>, speciesKey <int>,
#> #   acceptedTaxonKey <int>, acceptedScientificName <chr>, kingdom <chr>, phylum <chr>, order <chr>, family <chr>, genus <chr>, species <chr>, genericName <chr>,
#> #   specificEpithet <chr>, taxonRank <chr>, taxonomicStatus <chr>, dateIdentified <chr>, coordinateUncertaintyInMeters <dbl>, stateProvince <chr>, year <int>, month <int>,
#> #   day <int>, eventDate <date>, modified <chr>, lastInterpreted <chr>, references <chr>, license <chr>, geodeticDatum <chr>, class <chr>, countryCode <chr>, country <chr>,
#> #   rightsHolder <chr>, identifier <chr>, `http://unknown.org/nick` <chr>, verbatimEventDate <chr>, datasetName <chr>, gbifID <chr>, collectionCode <chr>, verbatimLocality <chr>,
#> #   occurrenceID <chr>, taxonID <chr>, catalogNumber <chr>, recordedBy <chr>, `http://unknown.org/occurrenceDetails` <chr>, institutionCode <chr>, rights <chr>, eventTime <chr>,
#> #   identificationID <chr>, informationWithheld <chr>, occurrenceRemarks <chr>, `http://unknown.org/recordedByOrcid` <chr>, identificationRemarks <chr>, infraspecificEpithet <chr>,
#> #   networkKeys <list>, individualCount <int>, continent <chr>, institutionID <chr>, county <chr>, identificationVerificationStatus <chr>, language <chr>, type <chr>,
#> #   locationAccordingTo <chr>, preparations <chr>, identifiedBy <chr>, georeferencedDate <chr>, higherGeography <chr>, nomenclaturalCode <chr>, georeferencedBy <chr>,
#> #   endDayOfYear <chr>, georeferenceVerificationStatus <chr>, locality <chr>, otherCatalogNumbers <chr>, organismID <chr>, previousIdentifications <chr>,
#> #   identificationQualifier <chr>, accessRights <chr>, higherClassification <chr>, collectionID <chr>, elevation <dbl>, elevationAccuracy <dbl>, organismQuantity <chr>,
#> #   eventID <chr>, habitat <chr>, dynamicProperties <chr>, verbatimSRS <chr>, verbatimCoordinateSystem <chr>, vernacularName <chr>, organismQuantityType <chr>,
#> #   samplingProtocol <chr>, fieldNotes <chr>, verbatimElevation <chr>, behavior <chr>, associatedTaxa <chr>
```

When you get data from multiple providers, the fields returned are slightly different, e.g.:


```r
df <- occ(query = 'Accipiter striatus', from = c('gbif', 'ecoengine'), limit = 25)
df$gbif$data$Accipiter_striatus
```

```
#> # A tibble: 25 x 71
#>    name  longitude latitude issues prov  key   scientificName datasetKey publishingOrgKey installationKey publishingCount… protocol lastCrawled lastParsed crawlId basisOfRecord
#>    <chr>     <dbl>    <dbl> <chr>  <chr> <chr> <chr>          <chr>      <chr>            <chr>           <chr>            <chr>    <chr>       <chr>        <int> <chr>        
#>  1 Acci…    -107.      35.1 cdrou… gbif  2542… Accipiter str… 50c9509d-… 28eb1a3f-1c15-4… 997448a8-f762-… US               DWC_ARC… 2020-02-06… 2020-02-0…     199 HUMAN_OBSERV…
#>  2 Acci…     -90.0     37.1 cdrou… gbif  2543… Accipiter str… 50c9509d-… 28eb1a3f-1c15-4… 997448a8-f762-… US               DWC_ARC… 2020-02-06… 2020-02-0…     199 HUMAN_OBSERV…
#>  3 Acci…     -99.3     36.5 cdrou… gbif  2543… Accipiter str… 50c9509d-… 28eb1a3f-1c15-4… 997448a8-f762-… US               DWC_ARC… 2020-02-06… 2020-02-0…     199 HUMAN_OBSERV…
#>  4 Acci…     -76.0     39.6 cdrou… gbif  2543… Accipiter str… 50c9509d-… 28eb1a3f-1c15-4… 997448a8-f762-… US               DWC_ARC… 2020-02-06… 2020-02-0…     199 HUMAN_OBSERV…
#>  5 Acci…     -73.5     40.7 gass84 gbif  2543… Accipiter str… 50c9509d-… 28eb1a3f-1c15-4… 997448a8-f762-… US               DWC_ARC… 2020-02-06… 2020-02-0…     199 HUMAN_OBSERV…
#>  6 Acci…    -118.      34.6 cdrou… gbif  2549… Accipiter str… 50c9509d-… 28eb1a3f-1c15-4… 997448a8-f762-… US               DWC_ARC… 2020-02-06… 2020-02-0…     199 HUMAN_OBSERV…
#>  7 Acci…    -121.      36.6 cdrou… gbif  2550… Accipiter str… 50c9509d-… 28eb1a3f-1c15-4… 997448a8-f762-… US               DWC_ARC… 2020-02-06… 2020-02-0…     199 HUMAN_OBSERV…
#>  8 Acci…     -97.3     27.6 cdrou… gbif  2550… Accipiter str… 50c9509d-… 28eb1a3f-1c15-4… 997448a8-f762-… US               DWC_ARC… 2020-02-06… 2020-02-0…     199 HUMAN_OBSERV…
#>  9 Acci…     -88.9     30.5 cdrou… gbif  2550… Accipiter str… 50c9509d-… 28eb1a3f-1c15-4… 997448a8-f762-… US               DWC_ARC… 2020-02-06… 2020-02-0…     199 HUMAN_OBSERV…
#> 10 Acci…     -96.9     33.1 cdrou… gbif  2550… Accipiter str… 50c9509d-… 28eb1a3f-1c15-4… 997448a8-f762-… US               DWC_ARC… 2020-02-06… 2020-02-0…     199 HUMAN_OBSERV…
#> # … with 15 more rows, and 55 more variables: taxonKey <int>, kingdomKey <int>, phylumKey <int>, classKey <int>, orderKey <int>, familyKey <int>, genusKey <int>, speciesKey <int>,
#> #   acceptedTaxonKey <int>, acceptedScientificName <chr>, kingdom <chr>, phylum <chr>, order <chr>, family <chr>, genus <chr>, species <chr>, genericName <chr>,
#> #   specificEpithet <chr>, taxonRank <chr>, taxonomicStatus <chr>, dateIdentified <chr>, coordinateUncertaintyInMeters <dbl>, stateProvince <chr>, year <int>, month <int>,
#> #   day <int>, eventDate <date>, modified <chr>, lastInterpreted <chr>, references <chr>, license <chr>, geodeticDatum <chr>, class <chr>, countryCode <chr>, country <chr>,
#> #   rightsHolder <chr>, identifier <chr>, `http://unknown.org/nick` <chr>, verbatimEventDate <chr>, datasetName <chr>, gbifID <chr>, collectionCode <chr>, verbatimLocality <chr>,
#> #   occurrenceID <chr>, taxonID <chr>, catalogNumber <chr>, recordedBy <chr>, `http://unknown.org/occurrenceDetails` <chr>, institutionCode <chr>, rights <chr>, eventTime <chr>,
#> #   identificationID <chr>, informationWithheld <chr>, occurrenceRemarks <chr>, `http://unknown.org/recordedByOrcid` <chr>
```

```r
df$ecoengine$data$Accipiter_striatus
```

```
#> # A tibble: 25 x 17
#>    longitude latitude url    key   observation_type name  country state_province begin_date end_date source remote_resource locality coordinate_unce… recorded_by last_modified prov 
#>        <dbl>    <dbl> <chr>  <chr> <chr>            <chr> <chr>   <chr>          <date>     <chr>    <chr>  <chr>           <chr>               <int> <chr>       <chr>         <chr>
#>  1     -117.     33.1 https… MVZ:… specimen         Acci… United… California     1908-10-16 1908-10… https… http://arctos.… Witch C…             3921 Collector(… 2015-01-08T1… ecoe…
#>  2     -117.     32.7 https… MVZ:… specimen         Acci… United… California     1908-12-20 1908-12… https… http://arctos.… San Die…            10190 Collector(… 2015-01-08T1… ecoe…
#>  3     -115.     33.4 https… MVZ:… specimen         Acci… United… California     1914-10-04 1914-10… https… http://arctos.… 0.25 mi…               30 Collector(… 2015-01-08T1… ecoe…
#>  4     -115.     33.4 https… MVZ:… specimen         Acci… United… California     1914-12-10 1914-12… https… http://arctos.… 0.75 mi…              289 Collector(… 2015-01-08T1… ecoe…
#>  5     -115.     33.4 https… MVZ:… specimen         Acci… United… California     1915-12-05 1915-12… https… http://arctos.… Palo Ve…               30 Collector(… 2015-01-08T1… ecoe…
#>  6     -119.     39.4 https… MVZ:… specimen         Acci… United… Nevada         1940-02-14 1940-02… https… http://arctos.… 5 mi SW…             9216 Collector(… 2015-01-08T1… ecoe…
#>  7     -118.     34.1 https… MVZ:… specimen         Acci… United… California     1895-11-15 1895-11… https… http://arctos.… Pasadena             6971 Collector(… 2015-01-08T1… ecoe…
#>  8     -118.     37.9 https… MVZ:… specimen         Acci… United… California     1917-09-19 1917-09… https… http://arctos.… Coyote …             1208 Collector(… 2015-01-08T1… ecoe…
#>  9     -118.     36.3 https… MVZ:… specimen         Acci… United… California     1918-04-07 1918-04… https… http://arctos.… Blanchu               804 Collector(… 2015-01-08T1… ecoe…
#> 10     -118.     34.1 https… MVZ:… specimen         Acci… United… California     1896-11-02 1896-11… https… http://arctos.… Pasadena             6971 Collector(… 2015-01-08T1… ecoe…
#> # … with 15 more rows
```

We provide a function `occ2df` that pulls out a few key columns needed for making maps:


```r
occ2df(df)
```

```
#> # A tibble: 50 x 6
#>    name                              longitude latitude prov  date       key       
#>    <chr>                                 <dbl>    <dbl> <chr> <date>     <chr>     
#>  1 Accipiter striatus Vieillot, 1808    -107.      35.1 gbif  2020-01-02 2542966593
#>  2 Accipiter striatus Vieillot, 1808     -90.0     37.1 gbif  2020-01-01 2543084396
#>  3 Accipiter striatus Vieillot, 1808     -99.3     36.5 gbif  2020-01-01 2543085372
#>  4 Accipiter striatus Vieillot, 1808     -76.0     39.6 gbif  2020-01-01 2543092704
#>  5 Accipiter striatus Vieillot, 1808     -73.5     40.7 gbif  2020-01-01 2543095325
#>  6 Accipiter striatus Vieillot, 1808    -118.      34.6 gbif  2020-01-03 2549993699
#>  7 Accipiter striatus Vieillot, 1808    -121.      36.6 gbif  2020-01-04 2550001873
#>  8 Accipiter striatus Vieillot, 1808     -97.3     27.6 gbif  2020-01-04 2550004653
#>  9 Accipiter striatus Vieillot, 1808     -88.9     30.5 gbif  2020-01-04 2550017314
#> 10 Accipiter striatus Vieillot, 1808     -96.9     33.1 gbif  2020-01-05 2550017778
#> # … with 40 more rows
```


### Fix names

One problem you often run in to is that there can be various names for the same taxon in any one source. For example:


```r
df <- occ(query = 'Pinus contorta', from = c('gbif', 'ecoengine'), limit = 50)
df$gbif$data$Pinus_contorta$name
```

```
#>  [1] "Pinus contorta Douglas ex Loudon"                 "Pinus contorta Douglas ex Loudon"                 "Pinus contorta Douglas ex Loudon"                
#>  [4] "Pinus contorta Douglas ex Loudon"                 "Pinus contorta var. contorta"                     "Pinus contorta Douglas ex Loudon"                
#>  [7] "Pinus contorta var. contorta"                     "Pinus contorta var. contorta"                     "Pinus contorta Douglas ex Loudon"                
#> [10] "Pinus contorta Douglas ex Loudon"                 "Pinus contorta Douglas ex Loudon"                 "Pinus contorta Douglas ex Loudon"                
#> [13] "Pinus contorta Douglas ex Loudon"                 "Pinus contorta Douglas ex Loudon"                 "Pinus contorta Douglas ex Loudon"                
#> [16] "Pinus contorta Douglas ex Loudon"                 "Pinus contorta Douglas ex Loudon"                 "Pinus contorta Douglas ex Loudon"                
#> [19] "Pinus contorta Douglas ex Loudon"                 "Pinus contorta Douglas ex Loudon"                 "Pinus contorta Douglas ex Loudon"                
#> [22] "Pinus contorta Douglas ex Loudon"                 "Pinus contorta Douglas ex Loudon"                 "Pinus contorta Douglas ex Loudon"                
#> [25] "Pinus contorta Douglas ex Loudon"                 "Pinus contorta var. contorta"                     "Pinus contorta Douglas ex Loudon"                
#> [28] "Pinus contorta Douglas ex Loudon"                 "Pinus contorta var. contorta"                     "Pinus contorta subsp. bolanderi (Parl.) Critchf."
#> [31] "Pinus contorta Douglas ex Loudon"                 "Pinus contorta var. contorta"                     "Pinus contorta subsp. bolanderi (Parl.) Critchf."
#> [34] "Pinus contorta var. contorta"                     "Pinus contorta var. contorta"                     "Pinus contorta Douglas ex Loudon"                
#> [37] "Pinus contorta Douglas ex Loudon"                 "Pinus contorta Douglas ex Loudon"                 "Pinus contorta var. contorta"                    
#> [40] "Pinus contorta var. contorta"                     "Pinus contorta var. contorta"                     "Pinus contorta Douglas ex Loudon"                
#> [43] "Pinus contorta Douglas ex Loudon"                 "Pinus contorta Douglas ex Loudon"                 "Pinus contorta Douglas ex Loudon"                
#> [46] "Pinus contorta Douglas ex Loudon"                 "Pinus contorta Douglas ex Loudon"                 "Pinus contorta Douglas ex Loudon"                
#> [49] "Pinus contorta Douglas ex Loudon"                 "Pinus contorta Douglas ex Loudon"
```

```r
df$ecoengine$data$Pinus_contorta$name
```

```
#>  [1] "Pinus contorta murrayana"        "Pinus contorta murrayana"        "Pinus contorta murrayana"        "Pinus contorta murrayana"        "Pinus contorta murrayana"       
#>  [6] "Pinus contorta murrayana"        "Pinus contorta murrayana"        "Pinus contorta murrayana"        "Pinus contorta murrayana"        "Pinus contorta"                 
#> [11] "Pinus contorta murrayana"        "Pinus contorta var. murrayana"   "Pinus contorta subsp. murrayana" "Pinus contorta murrayana"        "Pinus contorta murrayana"       
#> [16] "Pinus contorta murrayana"        "Pinus contorta var. murrayana"   "Pinus contorta murrayana"        "Pinus contorta murrayana"        "Pinus contorta"                 
#> [21] "Pinus contorta var. murrayana"   "Pinus contorta subsp. murrayana" "Pinus contorta var. murrayana"   "Pinus contorta subsp. murrayana" "Pinus contorta subsp. murrayana"
#> [26] "Pinus contorta subsp. murrayana" "Pinus contorta murrayana"        "Pinus contorta murrayana"        "Pinus contorta subsp. murrayana" "Pinus contorta murrayana"       
#> [31] "Pinus contorta var. murrayana"   "Pinus contorta murrayana"        "Pinus contorta murrayana"        "Pinus contorta murrayana"        "Pinus contorta subsp. murrayana"
#> [36] "Pinus contorta subsp. bolanderi" "Pinus contorta subsp. contorta"  "Pinus contorta subsp. murrayana" "Pinus contorta murrayana"        "Pinus contorta murrayana"       
#> [41] "Pinus contorta murrayana"        "Pinus contorta murrayana"        "Pinus contorta murrayana"        "Pinus contorta murrayana"        "Pinus contorta murrayana"       
#> [46] "Pinus contorta murrayana"        "Pinus contorta murrayana"        "Pinus contorta murrayana"        "Pinus contorta var. contorta"    "Pinus contorta subsp. murrayana"
```

This is fine, but when trying to make a map in which points are colored for each taxon, you can have many colors for a single taxon, where instead one color per taxon is more appropriate. There is a function in `spocc` called `fixnames`, which has a few options in which you can take the shortest names (usually just the plain binomials like _Homo sapiens_), or the original name queried, or a vector of names supplied by the user.


```r
df <- fixnames(df, how = 'query')
df$gbif$data$Pinus_contorta$name
```

```
#>  [1] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [11] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [21] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [31] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [41] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
```

```r
df$ecoengine$data$Pinus_contorta$name
```

```
#>  [1] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [11] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [21] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [31] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
#> [41] "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta" "Pinus contorta"
```

```r
df_comb <- occ2df(df)
head(df_comb); tail(df_comb)
```

```
#> # A tibble: 6 x 6
#>   name           longitude latitude prov  date       key       
#>   <chr>              <dbl>    <dbl> <chr> <date>     <chr>     
#> 1 Pinus contorta    -115.      50.9 gbif  2020-01-01 2543085192
#> 2 Pinus contorta      17.6     59.8 gbif  2020-01-01 2548826490
#> 3 Pinus contorta      19.2     64.0 gbif  2020-01-06 2549045731
#> 4 Pinus contorta      19.3     64.0 gbif  2020-01-06 2549053727
#> 5 Pinus contorta    -123.      49.3 gbif  2020-01-04 2550016817
#> 6 Pinus contorta    -106.      39.8 gbif  2020-01-07 2557738499
```

```
#> # A tibble: 6 x 6
#>   name           longitude latitude prov      date       key              
#>   <chr>              <dbl>    <dbl> <chr>     <date>     <chr>            
#> 1 Pinus contorta     -119.     38.1 ecoengine 1935-09-12 vtm:plot:71E15:7 
#> 2 Pinus contorta     -119.     37.8 ecoengine 1935-09-22 vtm:plot:76B115:3
#> 3 Pinus contorta     -119.     37.8 ecoengine 1935-09-15 vtm:plot:76C24:3 
#> 4 Pinus contorta     -119.     37.7 ecoengine 1935-09-07 vtm:plot:76D27:4 
#> 5 Pinus contorta     -124.     39.4 ecoengine 1930-10-31 POM213040        
#> 6 Pinus contorta     -121.     40.4 ecoengine 1960-07-18 CAS:DS:40775
```

## Clean data

All data cleaning functionality is in a new package [scrubr](https://github.com/ropensci/scrubr). [On CRAN](https://cran.r-project.org/package=scrubr).

## Make maps

All mapping functionality is now in a separate package [mapr](https://github.com/ropensci/mapr) (formerly known as `spoccutils`), to make `spocc` easier to maintain. [On CRAN](https://cran.r-project.org/package=mapr).
