spocc
========

[![Build Status](https://api.travis-ci.org/ropensci/spocc.png)](https://travis-ci.org/ropensci/spocc)

**`spocc` = SPecies OCCurrence data**


We (rOpenSci) have been writing R packages to interact with many sources of species occurrence data, including [GBIF][gbif], [Vertnet][vertnet], [BISON][bison], [iNaturalist][inat] and the [Berkeley ecoengine][ecoengine]. - and we'll continue to write wrappers for other sources. 

`spocc` is an R package to query and collect species occurrence data from many sources. The goal is to wrap functions in other R packages to make a seamless experience across data sources for the user. 

The inspiration for this comes from users requesting a more seamless experience across data sources, and from our work on a similar package for taxonomy data ([taxize][taxize]).

## Quick start

### Install

```coffee
install.packages("devtools")
library(devtools)
install_github("spocc", "ropensci")
library(spocc)
```

### Get data

Get data from GBIF

```coffee
occ(query='Accipiter striatus', from='gbif')
```

```
An object of class "occdat"
Slot "meta":
$time
[1] "2013-10-14 17:24:09 PDT"

$query
[1] "Accipiter striatus"

$from
[1] "gbif"

$type
[1] "sci"

$gbifopts
$gbifopts$taxonKey
[1] 2480612

$gbifopts$return
[1] "data"


$bisonopts
list()

$inatopts
list()

$npnopts
list()


Slot "data":
$gbif
                                name  longitude latitude prov
1  Accipiter striatus Vieillot, 1808 -122.26848 37.77092 gbif
2  Accipiter striatus Vieillot, 1808  -76.10433  4.72375 gbif
3  Accipiter striatus Vieillot, 1808  -97.27682 32.87642 gbif
4  Accipiter striatus Vieillot, 1808  -98.00115 32.80013 gbif
5  Accipiter striatus Vieillot, 1808 -122.78289 38.61318 gbif
6  Accipiter striatus Vieillot, 1808 -117.06342 32.55171 gbif
7  Accipiter striatus Vieillot, 1808  -76.54262 38.68847 gbif
8  Accipiter striatus Vieillot, 1808 -105.15587 40.67825 gbif
9  Accipiter striatus Vieillot, 1808         NA       NA gbif
10 Accipiter striatus Vieillot, 1808  -80.60072 32.70383 gbif
11 Accipiter striatus Vieillot, 1808  -76.42259 42.95494 gbif
12 Accipiter striatus Vieillot, 1808 -121.53113 37.34937 gbif
13 Accipiter striatus Vieillot, 1808 -118.30559 34.12857 gbif
14 Accipiter striatus Vieillot, 1808  -75.18940 40.32614 gbif
15 Accipiter striatus Vieillot, 1808  -82.35111 34.77389 gbif
16 Accipiter striatus Vieillot, 1808  -71.22694 42.42751 gbif
17 Accipiter striatus Vieillot, 1808  -75.77489 43.30850 gbif
18 Accipiter striatus Vieillot, 1808  -84.31470 39.33906 gbif
19 Accipiter striatus Vieillot, 1808 -103.72499 44.53957 gbif
20 Accipiter striatus Vieillot, 1808 -119.83272 39.55269 gbif
```

Get fine-grained detail over each data source by passing on parameters to the packge rnpn in this example.

```coffee
occ(query='Pinus contorta', from='npn', npnopts=list(startdate='2008-01-01', enddate='2011-12-31'))
```


```
An object of class "occdat"
Slot "meta":
$time
[1] "2013-10-14 17:26:34 PDT"

$query
[1] "Pinus contorta"

$from
[1] "npn"

$type
[1] "sci"

$gbifopts
list()

$bisonopts
list()

$inatopts
list()

$npnopts
$npnopts$startdate
[1] "2008-01-01"

$npnopts$enddate
[1] "2011-12-31"

$npnopts$speciesid
[1] 762



Slot "data":
$npn
          sciname  latitude   longitude   station_name                date phen_seq genus  epithet  genus_epithet
1  Pinus contorta 40.557255 -121.532234 CPP-LAVO-HORO1 2011-08-28 00:00:00       20 Pinus contorta Pinus contorta
2  Pinus contorta 40.557255 -121.532234 CPP-LAVO-HORO1 2011-11-09 00:00:00       20 Pinus contorta Pinus contorta
3  Pinus contorta 40.557255 -121.532234 CPP-LAVO-HORO1 2011-10-18 00:00:00       20 Pinus contorta Pinus contorta
4  Pinus contorta 40.557255 -121.532234 CPP-LAVO-HORO1 2011-10-27 00:00:00       20 Pinus contorta Pinus contorta
5  Pinus contorta 40.535763 -121.567291 CPP-LAVO-MANZ2 2011-07-29 00:00:00       20 Pinus contorta Pinus contorta
6  Pinus contorta 40.535763 -121.567291 CPP-LAVO-MANZ2 2011-07-18 00:00:00       20 Pinus contorta Pinus contorta
7  Pinus contorta 40.557255 -121.532234 CPP-LAVO-HORO1 2011-10-12 00:00:00       20 Pinus contorta Pinus contorta
8  Pinus contorta 40.535763 -121.567291 CPP-LAVO-MANZ2 2011-08-02 00:00:00       20 Pinus contorta Pinus contorta
9  Pinus contorta 40.535763 -121.567291 CPP-LAVO-MANZ2 2011-09-09 00:00:00      170 Pinus contorta Pinus contorta
10 Pinus contorta 40.557255 -121.532234 CPP-LAVO-HORO1 2011-09-02 00:00:00      170 Pinus contorta Pinus contorta
11 Pinus contorta 40.557255 -121.532234 CPP-LAVO-HORO1 2011-09-04 00:00:00      170 Pinus contorta Pinus contorta
12 Pinus contorta 40.557255 -121.532234 CPP-LAVO-HORO1 2011-09-16 00:00:00      170 Pinus contorta Pinus contorta
13 Pinus contorta 40.535763 -121.567291 CPP-LAVO-MANZ2 2011-09-11 00:00:00      170 Pinus contorta Pinus contorta
14 Pinus contorta 40.557255 -121.532234 CPP-LAVO-HORO1 2011-09-23 00:00:00      190 Pinus contorta Pinus contorta
15 Pinus contorta 40.557255 -121.532234 CPP-LAVO-HORO1 2011-09-18 00:00:00      190 Pinus contorta Pinus contorta
16 Pinus contorta 40.557255 -121.532234 CPP-LAVO-HORO1 2011-09-25 00:00:00      190 Pinus contorta Pinus contorta
17 Pinus contorta 40.557255 -121.532234 CPP-LAVO-HORO1 2011-07-13 00:00:00       10 Pinus contorta Pinus contorta
18 Pinus contorta 40.557255 -121.532234 CPP-LAVO-HORO1 2011-08-01 00:00:00       10 Pinus contorta Pinus contorta
19 Pinus contorta 40.557255 -121.532234 CPP-LAVO-HORO1 2011-07-25 00:00:00       10 Pinus contorta Pinus contorta
20 Pinus contorta 40.557255 -121.532234 CPP-LAVO-HORO1 2011-07-19 00:00:00       10 Pinus contorta Pinus contorta
21 Pinus contorta 40.557255 -121.532234 CPP-LAVO-HORO1 2011-07-21 00:00:00       10 Pinus contorta Pinus contorta
22 Pinus contorta 40.557255 -121.532234 CPP-LAVO-HORO1 2011-08-11 00:00:00       10 Pinus contorta Pinus contorta
23 Pinus contorta 40.557255 -121.532234 CPP-LAVO-HORO1 2011-08-15 00:00:00       10 Pinus contorta Pinus contorta
24 Pinus contorta 40.557255 -121.532234 CPP-LAVO-HORO1 2011-07-28 00:00:00       10 Pinus contorta Pinus contorta
25 Pinus contorta 40.557255 -121.532234 CPP-LAVO-HORO1 2011-08-08 00:00:00       10 Pinus contorta Pinus contorta
26 Pinus contorta 40.557255 -121.532234 CPP-LAVO-HORO1 2011-08-25 00:00:00       10 Pinus contorta Pinus contorta
27 Pinus contorta 40.535763 -121.567291 CPP-LAVO-MANZ2 2011-07-15 00:00:00       10 Pinus contorta Pinus contorta
28 Pinus contorta 40.557255 -121.532234 CPP-LAVO-HORO1 2011-08-04 00:00:00       10 Pinus contorta Pinus contorta
29 Pinus contorta 40.557255 -121.532234 CPP-LAVO-HORO1 2011-08-22 00:00:00       10 Pinus contorta Pinus contorta
30 Pinus contorta 40.535763 -121.567291 CPP-LAVO-MANZ2 2011-07-22 00:00:00       10 Pinus contorta Pinus contorta
31 Pinus contorta 40.557255 -121.532234 CPP-LAVO-HORO1 2011-08-18 00:00:00       10 Pinus contorta Pinus contorta
32 Pinus contorta 40.557255 -121.532234 CPP-LAVO-HORO1 2011-08-29 00:00:00       10 Pinus contorta Pinus contorta
     phenophase_name  color prov
1      Young needles Green1  npn
2      Young needles Green1  npn
3      Young needles Green1  npn
4      Young needles Green1  npn
5      Young needles Green1  npn
6      Young needles Green1  npn
7      Young needles Green1  npn
8      Young needles Green1  npn
9       Pollen cones Green2  npn
10      Pollen cones Green2  npn
11      Pollen cones Green2  npn
12      Pollen cones Green2  npn
13      Pollen cones Green2  npn
14 Open pollen cones Green2  npn
15 Open pollen cones Green2  npn
16 Open pollen cones Green2  npn
17  Emerging needles Green1  npn
18  Emerging needles Green1  npn
19  Emerging needles Green1  npn
20  Emerging needles Green1  npn
21  Emerging needles Green1  npn
22  Emerging needles Green1  npn
23  Emerging needles Green1  npn
24  Emerging needles Green1  npn
25  Emerging needles Green1  npn
26  Emerging needles Green1  npn
27  Emerging needles Green1  npn
28  Emerging needles Green1  npn
29  Emerging needles Green1  npn
30  Emerging needles Green1  npn
31  Emerging needles Green1  npn
32  Emerging needles Green1  npn
```

Get data from many sources in a single call

```coffee
npnopts <- list(startdate='2008-01-01', enddate='2011-12-31')
out <- occ(query='Pinus contorta', npnopts=npnopts)
df <- occ_todf(out)
list(head(df@data), tail(df@data))
```

```
[[1]]
                              name  longitude latitude prov
1 Pinus contorta Douglas ex Loudon    -3.6299 55.72854 gbif
2 Pinus contorta Douglas ex Loudon -120.04017 38.86617 gbif
3 Pinus contorta Douglas ex Loudon   -3.64374 55.71668 gbif
4 Pinus contorta Douglas ex Loudon    20.3504  63.7055 gbif
5 Pinus contorta Douglas ex Loudon    21.6093  66.0225 gbif
6 Pinus contorta Douglas ex Loudon -124.12111 46.94306 gbif

[[2]]
              name   longitude  latitude prov
157 Pinus contorta -121.567291 40.535763  npn
158 Pinus contorta -121.532234 40.557255  npn
159 Pinus contorta -121.532234 40.557255  npn
160 Pinus contorta -121.567291 40.535763  npn
161 Pinus contorta -121.532234 40.557255  npn
162 Pinus contorta -121.532234 40.557255  npn

```

### Make maps

**rCharts**

```coffee
spp <- c('Danaus plexippus','Accipiter striatus','Pinus contorta','Puma concolor','Ursus americanus','Gymnogyps californianus')
dat <- lapply(spp, function(x) occ(query=x, from='gbif', gbifopts=list(georeferenced=TRUE)))
dat <- occmany_todf(dat)@data
maprcharts(dat, map_provider="Acetate.terrain", palette_color="OrangeRed")
```

*map will be here later*


**Github gist**

```coffee
spp <- c('Danaus plexippus','Accipiter striatus','Pinus contorta')
dat <- lapply(spp, function(x) occ(query=x, from='gbif', gbifopts=list(georeferenced=TRUE)))
dat <- occmany_todf(dat)@data
mapgist(data=dat, color=c("#976AAE","#6B944D","#BD5945"))
```

*map will be here later*


**CartoDB**

```coffee
install_github("cartodb-r", "Vizzuality", subdir="CartoDB")
library(CartoDB)
tmp <- occ(query='Puma concolor', from='gbif', gbifopts=list(limit=500, 
   georeferenced=TRUE, country="US"))
data <- occ_todf(tmp)@data
mapcartodb(data, "pumamap", c("name","longitude","latitude"), "recology")
```

*map will be here later*


**Shiny**

```coffee
mapshiny()
```

*map will be here later*


**ggplot2**

```coffee
mapggplot2()
...
```

*map will be here later*

[gbif]: https://github.com/ropensci/rgbif
[vertnet]: https://github.com/ropensci/rvertnet
[bison]: https://github.com/ropensci/rbison
[inat]: https://github.com/ropensci/rinat
[taxize]: https://github.com/ropensci/taxize
[ecoengine]: https://github.com/ropensci/ecoengine