occdat
========

**`occdat` = species OCCurrence DATa**


We (rOpenSci) have been writing R packages to interact with many sources of species occurrence data, including [GBIF][gbif], [Vertnet][vertnet], [BISON][bison], and [iNaturalist][inat] - and we'll continue to write wrappers for other sources. 

`occdat` is an R package to query and collect species occurrence data from many sources. The goal is to wrap functions in other R packages to make a seamless experience across data sources for the user. 

For example, instead of searching for data in GBIF like 

```coffee
library(rgbif)
occurrencelist("Puma concolor")
```

And then data from BISON like 

```coffee
library(rbison)
bison("Puma concolor")
```

and then combine them somehow, we can simply do

```coffee
occ("Puma concolor", from = c('gbif', 'bison'))
```

and get a combined data set from the two data sources. We could even combine some functionality from `taxize` to clean taxonomic names. We'll see what happens...

The inspiration for this comes from users requesting a more seamless experience across data sources, and from our work on a similar package for taxonomy data ([taxize][taxize]).

[gbif]: https://github.com/ropensci/rgbif
[vertnet]: https://github.com/ropensci/rvertnet
[bison]: https://github.com/ropensci/rbison
[inat]: https://github.com/ropensci/rinat
[taxize]: https://github.com/ropensci/taxize_