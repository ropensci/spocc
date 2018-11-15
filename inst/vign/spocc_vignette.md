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

5. [Biodiversity Information Serving Our Nation](https://bison.usgs.gov/) (via `rbison`)
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
#> Occurrences - Found: 737,289, Returned: 500
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
#> # A tibble: 500 x 123
#>    name  longitude latitude prov  issues    key datasetKey publishingOrgKey
#>    <chr>     <dbl>    <dbl> <chr> <chr>   <int> <chr>      <chr>           
#>  1 Acci…    -104.      20.7 gbif  cdrou… 1.81e9 50c9509d-… 28eb1a3f-1c15-4…
#>  2 Acci…     -98.6     33.8 gbif  cdrou… 1.81e9 50c9509d-… 28eb1a3f-1c15-4…
#>  3 Acci…     -74.1     40.1 gbif  cdrou… 1.81e9 50c9509d-… 28eb1a3f-1c15-4…
#>  4 Acci…    -122.      38.0 gbif  cdrou… 1.80e9 50c9509d-… 28eb1a3f-1c15-4…
#>  5 Acci…    -122.      37.2 gbif  cdrou… 1.81e9 50c9509d-… 28eb1a3f-1c15-4…
#>  6 Acci…    -122.      37.0 gbif  cdrou… 1.80e9 50c9509d-… 28eb1a3f-1c15-4…
#>  7 Acci…    -103.      50.1 gbif  cdrou… 1.80e9 50c9509d-… 28eb1a3f-1c15-4…
#>  8 Acci…    -122.      38.0 gbif  cdrou… 1.80e9 50c9509d-… 28eb1a3f-1c15-4…
#>  9 Acci…    -115.      36.2 gbif  cdrou… 1.81e9 50c9509d-… 28eb1a3f-1c15-4…
#> 10 Acci…    -122.      37.1 gbif  cdrou… 1.81e9 50c9509d-… 28eb1a3f-1c15-4…
#> # ... with 490 more rows, and 115 more variables: networkKeys <list>,
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
#> #   identifier <chr>, informationWithheld <chr>, verbatimEventDate <chr>,
#> #   datasetName <chr>, verbatimLocality <chr>, gbifID <chr>,
#> #   collectionCode <chr>, occurrenceID <chr>, taxonID <chr>,
#> #   catalogNumber <chr>, recordedBy <chr>,
#> #   `http://unknown.org/occurrenceDetails` <chr>, institutionCode <chr>,
#> #   rights <chr>, eventTime <chr>,
#> #   `http://unknown.org/http_//rs.gbif.org/terms/1.0/Multimedia` <chr>,
#> #   identificationID <chr>, occurrenceRemarks <chr>,
#> #   identificationRemarks <chr>, elevation <dbl>, elevationAccuracy <dbl>,
#> #   eventID <chr>, organismQuantity <chr>, georeferenceProtocol <chr>,
#> #   dynamicProperties <chr>, verbatimSRS <chr>, county <chr>,
#> #   verbatimCoordinateSystem <chr>, locality <chr>, eventRemarks <chr>,
#> #   `http://unknown.org/http_//rs.tdwg.org/dwc/terms/MeasurementOrFact` <chr>,
#> #   vernacularName <chr>,
#> #   `http://unknown.org/http_//rs.tdwg.org/dwc/terms/ResourceRelationship` <chr>,
#> #   organismQuantityType <chr>, samplingProtocol <chr>,
#> #   identifiedBy <chr>, recordNumber <chr>, habitat <chr>,
#> #   preparations <chr>, sex <chr>, infraspecificEpithet <chr>,
#> #   continent <chr>, institutionID <chr>, language <chr>, type <chr>,
#> #   verbatimElevation <chr>, higherGeography <chr>,
#> #   nomenclaturalCode <chr>, dataGeneralizations <chr>, organismID <chr>,
#> #   ownerInstitutionCode <chr>, startDayOfYear <chr>, datasetID <chr>,
#> #   accessRights <chr>, higherClassification <chr>, collectionID <chr>,
#> #   individualCount <int>, …
```

When you get data from multiple providers, the fields returned are slightly different, e.g.:


```r
df <- occ(query = 'Accipiter striatus', from = c('gbif', 'ecoengine'), limit = 25)
df$gbif$data$Accipiter_striatus
```

```
#> # A tibble: 25 x 69
#>    name  longitude latitude issues prov     key datasetKey publishingOrgKey
#>    <chr>     <dbl>    <dbl> <chr>  <chr>  <int> <chr>      <chr>           
#>  1 Acci…    -104.      20.7 cdrou… gbif  1.81e9 50c9509d-… 28eb1a3f-1c15-4…
#>  2 Acci…     -98.6     33.8 cdrou… gbif  1.81e9 50c9509d-… 28eb1a3f-1c15-4…
#>  3 Acci…     -74.1     40.1 cdrou… gbif  1.81e9 50c9509d-… 28eb1a3f-1c15-4…
#>  4 Acci…    -122.      38.0 cdrou… gbif  1.80e9 50c9509d-… 28eb1a3f-1c15-4…
#>  5 Acci…    -122.      37.2 cdrou… gbif  1.81e9 50c9509d-… 28eb1a3f-1c15-4…
#>  6 Acci…    -122.      37.0 cdrou… gbif  1.80e9 50c9509d-… 28eb1a3f-1c15-4…
#>  7 Acci…    -103.      50.1 cdrou… gbif  1.80e9 50c9509d-… 28eb1a3f-1c15-4…
#>  8 Acci…    -122.      38.0 cdrou… gbif  1.80e9 50c9509d-… 28eb1a3f-1c15-4…
#>  9 Acci…    -115.      36.2 cdrou… gbif  1.81e9 50c9509d-… 28eb1a3f-1c15-4…
#> 10 Acci…    -122.      37.1 cdrou… gbif  1.81e9 50c9509d-… 28eb1a3f-1c15-4…
#> # ... with 15 more rows, and 61 more variables: networkKeys <list>,
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
#> #   identifier <chr>, informationWithheld <chr>, verbatimEventDate <chr>,
#> #   datasetName <chr>, verbatimLocality <chr>, gbifID <chr>,
#> #   collectionCode <chr>, occurrenceID <chr>, taxonID <chr>,
#> #   catalogNumber <chr>, recordedBy <chr>,
#> #   `http://unknown.org/occurrenceDetails` <chr>, institutionCode <chr>,
#> #   rights <chr>, eventTime <chr>,
#> #   `http://unknown.org/http_//rs.gbif.org/terms/1.0/Multimedia` <chr>,
#> #   identificationID <chr>, occurrenceRemarks <chr>
```

```r
df$ecoengine$data$Accipiter_striatus
```

```
#> # A tibble: 25 x 17
#>    longitude latitude url   key   observation_type name  country
#>        <dbl>    <dbl> <chr> <chr> <chr>            <chr> <chr>  
#>  1     -123.     38.0 http… CAS:… specimen         Acci… United…
#>  2     -123.     38.0 http… CAS:… specimen         Acci… United…
#>  3     -123.     38.0 http… CAS:… specimen         Acci… United…
#>  4     -123.     38.0 http… CAS:… specimen         Acci… United…
#>  5     -123.     38.0 http… CAS:… specimen         Acci… United…
#>  6     -123.     38.0 http… CAS:… specimen         Acci… United…
#>  7     -123.     38.0 http… CAS:… specimen         Acci… United…
#>  8     -122.     37.6 http… CAS:… specimen         Acci… United…
#>  9       NA      NA   http… CAS:… specimen         Acci… United…
#> 10     -122.     37.7 http… CAS:… specimen         Acci… United…
#> # ... with 15 more rows, and 10 more variables: state_province <chr>,
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
#>    name               longitude latitude prov  date       key       
#>    <chr>                  <dbl>    <dbl> <chr> <date>     <chr>     
#>  1 Accipiter striatus    -104.      20.7 gbif  2018-01-27 1806372635
#>  2 Accipiter striatus     -98.6     33.8 gbif  2018-01-21 1806341314
#>  3 Accipiter striatus     -74.1     40.1 gbif  2018-01-26 1806363338
#>  4 Accipiter striatus    -122.      38.0 gbif  2018-01-01 1802760979
#>  5 Accipiter striatus    -122.      37.2 gbif  2018-01-20 1806339729
#>  6 Accipiter striatus    -122.      37.0 gbif  2018-01-01 1802763269
#>  7 Accipiter striatus    -103.      50.1 gbif  2018-01-04 1802777994
#>  8 Accipiter striatus    -122.      38.0 gbif  2018-01-06 1802790830
#>  9 Accipiter striatus    -115.      36.2 gbif  2018-01-23 1806356037
#> 10 Accipiter striatus    -122.      37.1 gbif  2018-01-01 1807330165
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
#> 1 Pinus contorta    -110.      45.0 gbif  2018-01-18 1805419334
#> 2 Pinus contorta      17.6     59.8 gbif  2018-01-01 1821183578
#> 3 Pinus contorta    -110.      44.9 gbif  2018-01-18 1805419531
#> 4 Pinus contorta    -135.      57.1 gbif  2018-01-14 1805399256
#> 5 Pinus contorta    -113.      47.2 gbif  2018-01-06 1802781699
#> 6 Pinus contorta    -135.      57.1 gbif  2018-01-06 1802784638
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
