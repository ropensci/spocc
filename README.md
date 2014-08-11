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
```

```coffee
out
```

```coffee
Summary of results - occurrences found for:
 gbif  : 25 records across 1 species
 bison :  0 records across 1 species
 inat  :  0 records across 1 species
 ebird :  0 records across 1 species
 ecoengine :  0 records across 1 species
 antweb :  0 records across 1 species
```

```coffee
out$gbif # just gbif data
```

```coffee
Species [Accipiter striatus (25)]
First 10 rows of [Accipiter_striatus]

                 name  longitude latitude prov       key
1  Accipiter striatus  -72.52547 43.13234 gbif 891035349
2  Accipiter striatus  -97.19930 32.86027 gbif 891038901
3  Accipiter striatus  -97.65347 30.15791 gbif 891040018
4  Accipiter striatus  -71.72514 18.26982 gbif 891035119
5  Accipiter striatus -122.43980 37.48967 gbif 891040169
6  Accipiter striatus  -76.64497 41.85597 gbif 891043765
7  Accipiter striatus  -73.06720 43.63152 gbif 891048899
8  Accipiter striatus  -99.09873 26.49104 gbif 891049443
9  Accipiter striatus -117.14734 32.70358 gbif 891056214
10 Accipiter striatus  -97.88279 26.10227 gbif 891050439
..                ...        ...      ...  ...       ...
```

Get fine-grained detail over each data source by passing on parameters to the packge rebird in this example.

```coffee
out <- occ(query='Setophaga caerulescens', from='ebird', ebirdopts=list(region='US'))
out$ebird # just ebird data
```


```
Species [Setophaga caerulescens (25)]
First 10 rows of [Setophaga_caerulescens]

                     name longitude latitude  prov                     comName howMany    locID
1  Setophaga caerulescens -82.27411 35.71525 ebird Black-throated Blue Warbler       3  L808055
2  Setophaga caerulescens -81.68619 36.16935 ebird Black-throated Blue Warbler       1 L2377362
3  Setophaga caerulescens -73.05840 44.76782 ebird Black-throated Blue Warbler       1 L1042249
4  Setophaga caerulescens -83.91559 35.23377 ebird Black-throated Blue Warbler       3 L1117355
5  Setophaga caerulescens -71.33629 44.07229 ebird Black-throated Blue Warbler       1 L3019553
6  Setophaga caerulescens -69.88103 44.53983 ebird Black-throated Blue Warbler       1  L668744
7  Setophaga caerulescens -83.03123 35.15585 ebird Black-throated Blue Warbler       4 L3018347
8  Setophaga caerulescens -72.36832 44.42826 ebird Black-throated Blue Warbler       1 L3016946
9  Setophaga caerulescens -76.28847 42.43226 ebird Black-throated Blue Warbler       1  L453322
10 Setophaga caerulescens -72.19843 42.93351 ebird Black-throated Blue Warbler       2  L160223
..                    ...       ...      ...   ...                         ...     ...      ...
Variables not shown: locName (chr), locationPrivate (lgl), obsDt (chr), obsReviewed (lgl), obsValid
     (lgl)
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

![leafletmap](http://f.cl.ly/items/3w2Y1E3Z0T2T2z40310K/Screen%20Shot%202014-02-09%20at%2010.38.10%20PM.png)


**Github gist**

```coffee
spp <- c('Danaus plexippus','Accipiter striatus','Pinus contorta')
dat <- occ(query=spp, from='gbif', gbifopts=list(hasCoordinate=TRUE))
dat <- fixnames(dat)
dat <- occ2df(dat)
mapgist(data=dat, color=c("#976AAE","#6B944D","#BD5945"))
```

![gistmap](http://f.cl.ly/items/343l2G0A2J3T0n2t433W/Screen%20Shot%202014-02-09%20at%2010.40.57%20PM.png)


**ggplot2**

```coffee
ecoengine_data <- occ(query = 'Lynx rufus californicus', from = 'ecoengine')
mapggplot(ecoengine_data)
```

![ggplot2map](http://f.cl.ly/items/1U1R0E0G392l2q362V33/Screen%20Shot%202014-02-09%20at%2010.44.59%20PM.png)


**Base R plots**

```coffee
spnames <- c('Accipiter striatus', 'Setophaga caerulescens', 'Spinus tristis')
out <- occ(query=spnames, from='gbif', gbifopts=list(hasCoordinate=TRUE))
plot(out, cex=1, pch=10)
```

![basremap](http://f.cl.ly/items/3O13330W3w3Z0H3u1X0s/Screen%20Shot%202014-02-09%20at%2010.46.25%20PM.png)


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

[![ropensci footer](http://ropensci.org/public_images/github_footer.png)](http://ropensci.org)

[gbif]: https://github.com/ropensci/rgbif
[vertnet]: https://github.com/ropensci/rvertnet
[bison]: https://github.com/ropensci/rbison
[inat]: https://github.com/ropensci/rinat
[taxize]: https://github.com/ropensci/taxize
[ecoengine]: https://github.com/ropensci/ecoengine
[antweb]: http://antweb.org/
