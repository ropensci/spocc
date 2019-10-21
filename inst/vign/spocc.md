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
#> Occurrences - Found: 963,463, Returned: 500
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
#> # A tibble: 500 x 101
#>    name  longitude latitude prov  issues key   scientificName datasetKey
#>    <chr>     <dbl>    <dbl> <chr> <chr>  <chr> <chr>          <chr>     
#>  1 Acci…    -107.      24.0 gbif  cdrou… 1990… Accipiter str… 50c9509d-…
#>  2 Acci…     -97.3     37.7 gbif  cdrou… 1990… Accipiter str… 50c9509d-…
#>  3 Acci…     -98.4     30.3 gbif  cdrou… 1993… Accipiter str… 50c9509d-…
#>  4 Acci…     -86.6     39.2 gbif  cdrou… 2012… Accipiter str… 50c9509d-…
#>  5 Acci…     -97.0     32.9 gbif  cdrou… 1990… Accipiter str… 50c9509d-…
#>  6 Acci…     -98.4     30.4 gbif  cdrou… 1993… Accipiter str… 50c9509d-…
#>  7 Acci…     -98.0     30.1 gbif  cdrou… 2006… Accipiter str… 50c9509d-…
#>  8 Acci…    -117.      32.9 gbif  cdrou… 1990… Accipiter str… 50c9509d-…
#>  9 Acci…    -135.      57.0 gbif  cdrou… 1990… Accipiter str… 50c9509d-…
#> 10 Acci…    -135.      57.0 gbif  cdrou… 1990… Accipiter str… 50c9509d-…
#> # … with 490 more rows, and 93 more variables: publishingOrgKey <chr>,
#> #   networkKeys <list>, installationKey <chr>, publishingCountry <chr>,
#> #   protocol <chr>, lastCrawled <chr>, lastParsed <chr>, crawlId <int>,
#> #   basisOfRecord <chr>, taxonKey <int>, kingdomKey <int>,
#> #   phylumKey <int>, classKey <int>, orderKey <int>, familyKey <int>,
#> #   genusKey <int>, speciesKey <int>, acceptedTaxonKey <int>,
#> #   acceptedScientificName <chr>, kingdom <chr>, phylum <chr>,
#> #   order <chr>, family <chr>, genus <chr>, species <chr>,
#> #   genericName <chr>, specificEpithet <chr>, taxonRank <chr>,
#> #   taxonomicStatus <chr>, coordinateUncertaintyInMeters <dbl>,
#> #   stateProvince <chr>, year <int>, month <int>, day <int>,
#> #   eventDate <date>, modified <chr>, lastInterpreted <chr>,
#> #   references <chr>, license <chr>, geodeticDatum <chr>, class <chr>,
#> #   countryCode <chr>, country <chr>, rightsHolder <chr>,
#> #   identifier <chr>, `http://unknown.org/nick` <chr>,
#> #   informationWithheld <chr>, verbatimEventDate <chr>, datasetName <chr>,
#> #   verbatimLocality <chr>, gbifID <chr>, collectionCode <chr>,
#> #   occurrenceID <chr>, taxonID <chr>, catalogNumber <chr>,
#> #   recordedBy <chr>, `http://unknown.org/occurrenceDetails` <chr>,
#> #   institutionCode <chr>, rights <chr>, eventTime <chr>,
#> #   dateIdentified <chr>, identificationID <chr>, occurrenceRemarks <chr>,
#> #   identificationRemarks <chr>, individualCount <int>, continent <chr>,
#> #   institutionID <chr>, county <chr>,
#> #   identificationVerificationStatus <chr>, language <chr>, type <chr>,
#> #   preparations <chr>, locationAccordingTo <chr>, identifiedBy <chr>,
#> #   georeferencedDate <chr>, higherGeography <chr>,
#> #   nomenclaturalCode <chr>, georeferencedBy <chr>, endDayOfYear <chr>,
#> #   georeferenceVerificationStatus <chr>, locality <chr>,
#> #   otherCatalogNumbers <chr>, organismID <chr>,
#> #   previousIdentifications <chr>, identificationQualifier <chr>,
#> #   accessRights <chr>, collectionID <chr>, higherClassification <chr>,
#> #   infraspecificEpithet <chr>, vernacularName <chr>, fieldNotes <chr>,
#> #   verbatimElevation <chr>, behavior <chr>
```

When you get data from multiple providers, the fields returned are slightly different, e.g.:


```r
df <- occ(query = 'Accipiter striatus', from = c('gbif', 'ecoengine'), limit = 25)
df$gbif$data$Accipiter_striatus
```

```
#> # A tibble: 25 x 71
#>    name  longitude latitude issues prov  key   scientificName datasetKey
#>    <chr>     <dbl>    <dbl> <chr>  <chr> <chr> <chr>          <chr>     
#>  1 Acci…    -107.      24.0 cdrou… gbif  1990… Accipiter str… 50c9509d-…
#>  2 Acci…     -97.3     37.7 cdrou… gbif  1990… Accipiter str… 50c9509d-…
#>  3 Acci…     -98.4     30.3 cdrou… gbif  1993… Accipiter str… 50c9509d-…
#>  4 Acci…     -86.6     39.2 cdrou… gbif  2012… Accipiter str… 50c9509d-…
#>  5 Acci…     -97.0     32.9 cdrou… gbif  1990… Accipiter str… 50c9509d-…
#>  6 Acci…     -98.4     30.4 cdrou… gbif  1993… Accipiter str… 50c9509d-…
#>  7 Acci…     -98.0     30.1 cdrou… gbif  2006… Accipiter str… 50c9509d-…
#>  8 Acci…    -117.      32.9 cdrou… gbif  1990… Accipiter str… 50c9509d-…
#>  9 Acci…    -135.      57.0 cdrou… gbif  1990… Accipiter str… 50c9509d-…
#> 10 Acci…    -135.      57.0 cdrou… gbif  1990… Accipiter str… 50c9509d-…
#> # … with 15 more rows, and 63 more variables: publishingOrgKey <chr>,
#> #   networkKeys <list>, installationKey <chr>, publishingCountry <chr>,
#> #   protocol <chr>, lastCrawled <chr>, lastParsed <chr>, crawlId <int>,
#> #   basisOfRecord <chr>, taxonKey <int>, kingdomKey <int>,
#> #   phylumKey <int>, classKey <int>, orderKey <int>, familyKey <int>,
#> #   genusKey <int>, speciesKey <int>, acceptedTaxonKey <int>,
#> #   acceptedScientificName <chr>, kingdom <chr>, phylum <chr>,
#> #   order <chr>, family <chr>, genus <chr>, species <chr>,
#> #   genericName <chr>, specificEpithet <chr>, taxonRank <chr>,
#> #   taxonomicStatus <chr>, coordinateUncertaintyInMeters <dbl>,
#> #   stateProvince <chr>, year <int>, month <int>, day <int>,
#> #   eventDate <date>, modified <chr>, lastInterpreted <chr>,
#> #   references <chr>, license <chr>, geodeticDatum <chr>, class <chr>,
#> #   countryCode <chr>, country <chr>, rightsHolder <chr>,
#> #   identifier <chr>, `http://unknown.org/nick` <chr>,
#> #   informationWithheld <chr>, verbatimEventDate <chr>, datasetName <chr>,
#> #   verbatimLocality <chr>, gbifID <chr>, collectionCode <chr>,
#> #   occurrenceID <chr>, taxonID <chr>, catalogNumber <chr>,
#> #   recordedBy <chr>, `http://unknown.org/occurrenceDetails` <chr>,
#> #   institutionCode <chr>, rights <chr>, eventTime <chr>,
#> #   dateIdentified <chr>, identificationID <chr>, occurrenceRemarks <chr>
```

```r
df$ecoengine$data$Accipiter_striatus
```

```
#> # A tibble: 25 x 17
#>    longitude latitude url   key   observation_type name  country
#>        <dbl>    <dbl> <chr> <chr> <chr>            <chr> <chr>  
#>  1    -117.      34.5 http… MVZ:… specimen         Acci… United…
#>  2    -117.      33.1 http… MVZ:… specimen         Acci… United…
#>  3    -119.      39.5 http… MVZ:… specimen         Acci… United…
#>  4    -118.      36.5 http… MVZ:… specimen         Acci… United…
#>  5    -124.      40.7 http… MVZ:… specimen         Acci… United…
#>  6     -94.6     39.1 http… MVZ:… specimen         Acci… United…
#>  7    -158.      67.0 http… MVZ:… specimen         Acci… United…
#>  8    -122.      37.5 http… MVZ:… specimen         Acci… United…
#>  9      NA       NA   http… MVZ:… specimen         Acci… United…
#> 10    -121.      39.3 http… MVZ:… specimen         Acci… United…
#> # … with 15 more rows, and 10 more variables: state_province <chr>,
#> #   begin_date <date>, end_date <chr>, source <chr>,
#> #   remote_resource <chr>, locality <chr>,
#> #   coordinate_uncertainty_in_meters <int>, recorded_by <chr>,
#> #   last_modified <chr>, prov <chr>
```

We provide a function `occ2df` that pulls out a few key columns needed for making maps:


```r
occ2df(df)
```

```
#> # A tibble: 50 x 6
#>    name                        longitude latitude prov  date       key     
#>    <chr>                           <dbl>    <dbl> <chr> <date>     <chr>   
#>  1 Accipiter striatus Vieillo…    -107.      24.0 gbif  2019-01-06 1990485…
#>  2 Accipiter striatus Vieillo…     -97.3     37.7 gbif  2019-01-18 1990616…
#>  3 Accipiter striatus Vieillo…     -98.4     30.3 gbif  2019-01-29 1993731…
#>  4 Accipiter striatus Vieillo…     -86.6     39.2 gbif  2019-01-26 2012971…
#>  5 Accipiter striatus Vieillo…     -97.0     32.9 gbif  2019-01-24 1990580…
#>  6 Accipiter striatus Vieillo…     -98.4     30.4 gbif  2019-01-31 1993731…
#>  7 Accipiter striatus Vieillo…     -98.0     30.1 gbif  2019-01-18 2006044…
#>  8 Accipiter striatus Vieillo…    -117.      32.9 gbif  2019-01-14 1990502…
#>  9 Accipiter striatus Vieillo…    -135.      57.0 gbif  2019-01-17 1990521…
#> 10 Accipiter striatus Vieillo…    -135.      57.0 gbif  2019-01-19 1990537…
#> # … with 40 more rows
```


### Fix names

One problem you often run in to is that there can be various names for the same taxon in any one source. For example:


```r
df <- occ(query = 'Pinus contorta', from = c('gbif', 'ecoengine'), limit = 50)
df$gbif$data$Pinus_contorta$name
```

```
#>  [1] "Pinus contorta Douglas ex Loudon"                
#>  [2] "Pinus contorta var. contorta"                    
#>  [3] "Pinus contorta var. contorta"                    
#>  [4] "Pinus contorta var. contorta"                    
#>  [5] "Pinus contorta Douglas ex Loudon"                
#>  [6] "Pinus contorta var. contorta"                    
#>  [7] "Pinus contorta subsp. bolanderi (Parl.) Critchf."
#>  [8] "Pinus contorta Douglas ex Loudon"                
#>  [9] "Pinus contorta Douglas ex Loudon"                
#> [10] "Pinus contorta Douglas ex Loudon"                
#> [11] "Pinus contorta var. contorta"                    
#> [12] "Pinus contorta Douglas ex Loudon"                
#> [13] "Pinus contorta Douglas ex Loudon"                
#> [14] "Pinus contorta Douglas ex Loudon"                
#> [15] "Pinus contorta subsp. bolanderi (Parl.) Critchf."
#> [16] "Pinus contorta Douglas ex Loudon"                
#> [17] "Pinus contorta Douglas ex Loudon"                
#> [18] "Pinus contorta var. contorta"                    
#> [19] "Pinus contorta Douglas ex Loudon"                
#> [20] "Pinus contorta var. contorta"                    
#> [21] "Pinus contorta Douglas ex Loudon"                
#> [22] "Pinus contorta Douglas ex Loudon"                
#> [23] "Pinus contorta var. contorta"                    
#> [24] "Pinus contorta var. contorta"                    
#> [25] "Pinus contorta Douglas ex Loudon"                
#> [26] "Pinus contorta Douglas ex Loudon"                
#> [27] "Pinus contorta var. contorta"                    
#> [28] "Pinus contorta Douglas ex Loudon"                
#> [29] "Pinus contorta var. murrayana (Balf.) Engelm."   
#> [30] "Pinus contorta var. contorta"                    
#> [31] "Pinus contorta Douglas ex Loudon"                
#> [32] "Pinus contorta Douglas ex Loudon"                
#> [33] "Pinus contorta var. contorta"                    
#> [34] "Pinus contorta Douglas ex Loudon"                
#> [35] "Pinus contorta Douglas ex Loudon"                
#> [36] "Pinus contorta var. contorta"                    
#> [37] "Pinus contorta Douglas ex Loudon"                
#> [38] "Pinus contorta Douglas ex Loudon"                
#> [39] "Pinus contorta var. contorta"                    
#> [40] "Pinus contorta var. contorta"                    
#> [41] "Pinus contorta Douglas ex Loudon"                
#> [42] "Pinus contorta Douglas ex Loudon"                
#> [43] "Pinus contorta Douglas ex Loudon"                
#> [44] "Pinus contorta Douglas ex Loudon"                
#> [45] "Pinus contorta Douglas ex Loudon"                
#> [46] "Pinus contorta Douglas ex Loudon"                
#> [47] "Pinus contorta Douglas ex Loudon"                
#> [48] "Pinus contorta Douglas ex Loudon"                
#> [49] "Pinus contorta Douglas ex Loudon"                
#> [50] "Pinus contorta var. contorta"
```

```r
df$ecoengine$data$Pinus_contorta$name
```

```
#>  [1] "Pinus contorta murrayana"        "Pinus contorta murrayana"       
#>  [3] "Pinus contorta murrayana"        "Pinus contorta murrayana"       
#>  [5] "Pinus contorta murrayana"        "Pinus contorta murrayana"       
#>  [7] "Pinus contorta murrayana"        "Pinus contorta murrayana"       
#>  [9] "Pinus contorta murrayana"        "Pinus contorta"                 
#> [11] "Pinus contorta murrayana"        "Pinus contorta var. murrayana"  
#> [13] "Pinus contorta subsp. murrayana" "Pinus contorta murrayana"       
#> [15] "Pinus contorta murrayana"        "Pinus contorta murrayana"       
#> [17] "Pinus contorta var. murrayana"   "Pinus contorta murrayana"       
#> [19] "Pinus contorta murrayana"        "Pinus contorta"                 
#> [21] "Pinus contorta var. murrayana"   "Pinus contorta subsp. murrayana"
#> [23] "Pinus contorta var. murrayana"   "Pinus contorta subsp. murrayana"
#> [25] "Pinus contorta subsp. murrayana" "Pinus contorta subsp. murrayana"
#> [27] "Pinus contorta murrayana"        "Pinus contorta murrayana"       
#> [29] "Pinus contorta subsp. murrayana" "Pinus contorta murrayana"       
#> [31] "Pinus contorta var. murrayana"   "Pinus contorta murrayana"       
#> [33] "Pinus contorta murrayana"        "Pinus contorta murrayana"       
#> [35] "Pinus contorta subsp. murrayana" "Pinus contorta subsp. bolanderi"
#> [37] "Pinus contorta subsp. contorta"  "Pinus contorta subsp. murrayana"
#> [39] "Pinus contorta murrayana"        "Pinus contorta murrayana"       
#> [41] "Pinus contorta murrayana"        "Pinus contorta murrayana"       
#> [43] "Pinus contorta murrayana"        "Pinus contorta murrayana"       
#> [45] "Pinus contorta murrayana"        "Pinus contorta murrayana"       
#> [47] "Pinus contorta murrayana"        "Pinus contorta murrayana"       
#> [49] "Pinus contorta var. contorta"    "Pinus contorta subsp. murrayana"
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
#> # A tibble: 6 x 6
#>   name           longitude latitude prov  date       key       
#>   <chr>              <dbl>    <dbl> <chr> <date>     <chr>     
#> 1 Pinus contorta     -124.     45.0 gbif  2019-01-24 1990578111
#> 2 Pinus contorta     -123.     49.3 gbif  2019-01-05 1986593119
#> 3 Pinus contorta     -124.     48.3 gbif  2019-01-28 1993746724
#> 4 Pinus contorta     -123.     49.3 gbif  2019-01-05 2265780725
#> 5 Pinus contorta     -123.     48.4 gbif  2019-01-29 2234754365
#> 6 Pinus contorta     -124.     48.4 gbif  2019-01-13 1990519039
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
