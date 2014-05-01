spocc
========

[![Build Status](https://api.travis-ci.org/ropensci/spocc.png)](https://travis-ci.org/ropensci/spocc)

**`spocc` = SPecies OCCurrence data**


At rOpenSci, we have been writing R packages to interact with many sources of species occurrence data, including [GBIF][gbif], [Vertnet][vertnet], [BISON][bison], [iNaturalist][inat], the [Berkeley ecoengine][ecoengine], and [AntWeb][antweb]. `spocc` is an R package to query and collect species occurrence data from many sources. The goal is to wrap functions in other R packages to make a seamless experience across data sources for the user.

The inspiration for this comes from users requesting a more seamless experience across data sources, and from our work on a similar package for taxonomy data ([taxize][taxize]).

### Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)

## Quick start

### Install

Install `spocc`

```coffee
install.packages("spocc", dependencies = TRUE)
```

Or the development version

```coffee
install.packages("devtools")
library(devtools)
install_github("ropensci/spocc")
library(spocc)
```

### Get data

Get data from GBIF

```coffee
out <- occ(query='Accipiter striatus', from='gbif')
out$gbif # just gbif data
```

```
$gbif
$gbif$meta
$gbif$meta$source
[1] "gbif"

$gbif$meta$time
[1] "2013-12-11 10:02:45 PST"

$gbif$meta$query
[1] "Accipiter striatus"

$gbif$meta$type
[1] "sci"

$gbif$meta$opts
list()


$gbif$data
$gbif$data$Accipiter_striatus
                                name       key  longitude latitude prov
1  Accipiter striatus Vieillot, 1808 773408845  -97.27682 32.87642 gbif
2  Accipiter striatus Vieillot, 1808 768992325  -76.10433  4.72375 gbif
3  Accipiter striatus Vieillot, 1808 773414146 -122.26848 37.77092 gbif
4  Accipiter striatus Vieillot, 1808 773440541  -98.00115 32.80013 gbif
5  Accipiter striatus Vieillot, 1808 773423188  -76.54262 38.68847 gbif
6  Accipiter striatus Vieillot, 1808 773432602 -122.78289 38.61318 gbif
7  Accipiter striatus Vieillot, 1808 773430206 -117.06342 32.55171 gbif
8  Accipiter striatus Vieillot, 1808 833024105 -105.15587 40.67825 gbif
9  Accipiter striatus Vieillot, 1808        NA         NA       NA gbif
10 Accipiter striatus Vieillot, 1808 579130954  -74.44419 40.54073 gbif
11 Accipiter striatus Vieillot, 1808 579131911  -76.69865 39.88886 gbif
12 Accipiter striatus Vieillot, 1808 579132307  -75.55195 39.60463 gbif
13 Accipiter striatus Vieillot, 1808 579134716  -96.97675 32.64104 gbif
14 Accipiter striatus Vieillot, 1808 579138808  -73.57194 41.00291 gbif
15 Accipiter striatus Vieillot, 1808 579149929 -123.96475 49.23553 gbif
16 Accipiter striatus Vieillot, 1808 579157816  -70.40314 41.68471 gbif
17 Accipiter striatus Vieillot, 1808 579125251  -84.13030 33.97565 gbif
18 Accipiter striatus Vieillot, 1808 579127561  -90.07058 30.01456 gbif
19 Accipiter striatus Vieillot, 1808 579128452 -105.20556 39.66553 gbif
20 Accipiter striatus Vieillot, 1808 818461023 -111.73395 33.36145 gbif

....(remainder of output cut off)
```

Get fine-grained detail over each data source by passing on parameters to the packge rebird in this example.

```coffee
out <- occ(query='Setophaga caerulescens', from='ebird', ebirdopts=list(region='US'))
out$ebird # just ebird data
```


```
$meta
$meta$source
[1] "ebird"

$meta$time
[1] "2013-12-11 10:04:37 PST"

$meta$query
[1] "Setophaga caerulescens"

$meta$type
[1] "sci"

$meta$opts
$meta$opts$region
[1] "US"



$data
$data$Setophaga_caerulescens
                       comName howMany      lat        lng    locID                                locName
1  Black-throated Blue Warbler       1 40.93444  -73.84513 L2374154            NY - Sarah Lawrence College
2  Black-throated Blue Warbler       1 25.73408  -80.31086  L200830                      A. D. Barnes Park
3  Black-throated Blue Warbler       1 26.17131  -80.16149  L710596          John D. Easterlin County Park
4  Black-throated Blue Warbler       1 26.23507  -80.19144  L818386         Coconut Creek-Pompano CBC area
5  Black-throated Blue Warbler       1 25.91066  -80.33196 L1875938                  Miami Lakes West Park
6  Black-throated Blue Warbler       1 25.32295  -80.83315  L123123        Everglades NP--Mahogany Hammock
7  Black-throated Blue Warbler       1 36.19909 -105.88400 L1824677                        Dixon/El Bosque
8  Black-throated Blue Warbler       1 25.67330  -80.15820  L127423             Bill Baggs Cape Florida SP
9  Black-throated Blue Warbler       1 28.79362  -82.52210 L2440885                                   Home
10 Black-throated Blue Warbler       1 25.73918  -80.30943 L1663905 Miami - AD Barnes Park - Nature Center
   locationPrivate            obsDt obsReviewed obsValid                name  prov
1             TRUE 2013-12-06 13:00        TRUE     TRUE Setophaga caerulescens ebird
2            FALSE 2013-12-06 12:04       FALSE     TRUE Setophaga caerulescens ebird
3            FALSE 2013-12-06 09:10       FALSE     TRUE Setophaga caerulescens ebird
4             TRUE 2013-12-05 08:45       FALSE     TRUE Setophaga caerulescens ebird
5             TRUE 2013-12-03 09:15       FALSE     TRUE Setophaga caerulescens ebird
6            FALSE 2013-12-01 11:20       FALSE     TRUE Setophaga caerulescens ebird
7             TRUE 2013-12-01 08:40        TRUE     TRUE Setophaga caerulescens ebird
8            FALSE 2013-12-01 06:50       FALSE     TRUE Setophaga caerulescens ebird
9             TRUE 2013-11-30 16:05        TRUE     TRUE Setophaga caerulescens ebird
10            TRUE       2013-11-28       FALSE     TRUE Setophaga caerulescens ebird
```

Get data from many sources in a single call

```coffee
ebirdopts = list(region='US'); gbifopts = list(country='US')
out <- occ(query='Setophaga caerulescens', from=c('gbif','bison','inat','ebird'), gbifopts=gbifopts, ebirdopts=ebirdopts)
head(occ2df(out)); tail(occ2df(out))
```

```
                    name  longitude latitude prov
1 Setophaga caerulescens -122.32551 37.26128 gbif
2 Setophaga caerulescens -117.04148 32.79913 gbif
3 Setophaga caerulescens  -87.61893 41.87652 gbif
4 Setophaga caerulescens  -80.79602 25.39812 gbif
5 Setophaga caerulescens  -80.31086 25.73408 gbif
6 Setophaga caerulescens  -69.99167 41.91779 gbif

                     name longitude   latitude  prov
91 Setophaga caerulescens  25.91066  -80.33196 ebird
92 Setophaga caerulescens  25.32295  -80.83315 ebird
93 Setophaga caerulescens  36.19909 -105.88400 ebird
94 Setophaga caerulescens  25.67330  -80.15820 ebird
95 Setophaga caerulescens  28.79362  -82.52210 ebird
96 Setophaga caerulescens  25.73918  -80.30943 ebird
```

### Make maps

**Leaflet**

```coffee
spp <- c('Danaus plexippus','Accipiter striatus','Pinus contorta')
dat <- occ(query = spp, from = 'gbif', gbifopts = list(hasCoordinate=TRUE))
data <- occ2df(dat)
mapleaflet(data = data, dest = ".")
```

![](http://f.cl.ly/items/3w2Y1E3Z0T2T2z40310K/Screen%20Shot%202014-02-09%20at%2010.38.10%20PM.png)


**Github gist**

```coffee
spp <- c('Danaus plexippus','Accipiter striatus','Pinus contorta')
dat <- occ(query=spp, from='gbif', gbifopts=list(hasCoordinate=TRUE))
dat <- fixnames(dat)
dat <- occ2df(dat)
mapgist(data=dat, color=c("#976AAE","#6B944D","#BD5945"))
```

![](http://f.cl.ly/items/343l2G0A2J3T0n2t433W/Screen%20Shot%202014-02-09%20at%2010.40.57%20PM.png)


**ggplot2**

```coffee
ecoengine_data <- occ(query = 'Lynx rufus californicus', from = 'ecoengine')
mapggplot(ecoengine_data)
```

![](http://f.cl.ly/items/1U1R0E0G392l2q362V33/Screen%20Shot%202014-02-09%20at%2010.44.59%20PM.png)


**Base R plots**

```coffee
spnames <- c('Accipiter striatus', 'Setophaga caerulescens', 'Spinus tristis')
out <- occ(query=spnames, from='gbif', gbifopts=list(hasCoordinate=TRUE))
plot(out, cex=1, pch=10)
```

![](http://f.cl.ly/items/3O13330W3w3Z0H3u1X0s/Screen%20Shot%202014-02-09%20at%2010.46.25%20PM.png)


Please report any issues or bugs](https://github.com/ropensci/spocc/issues).

License: MIT

This package is part of the [rOpenSci](http://ropensci.org/packages) project.

To cite package `spocc` in publications use:

```coffee
To cite package ‘spocc’ in publications use:

  Scott Chamberlain, Karthik Ram and Ted Hart (2014). spocc: R interface to many species occurrence data sources. R package version 0.1.0.
  https://github.com/ropensci/spocc

A BibTeX entry for LaTeX users is

  @Manual{,
    title = {spocc: R interface to many species occurrence data sources},
    author = {Scott Chamberlain and Karthik Ram and Ted Hart},
    year = {2014},
    note = {R package version 0.1.0},
    url = {https://github.com/ropensci/spocc},
  }
```

Get citation information for `spocc` in R doing `citation(package = 'spocc')`

[![](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)

[gbif]: https://github.com/ropensci/rgbif
[vertnet]: https://github.com/ropensci/rvertnet
[bison]: https://github.com/ropensci/rbison
[inat]: https://github.com/ropensci/rinat
[taxize]: https://github.com/ropensci/taxize
[ecoengine]: https://github.com/ropensci/ecoengine
[antweb]: http://antweb.org/
