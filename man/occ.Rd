\name{occ}
\alias{occ}
\title{Search for species occurrence data across many data sources.}
\usage{
occ(query = NULL, from = c("gbif", "bison", "inat", "ebird"),
  rank = "species", type = "sci", gbifopts = list(), bisonopts = list(),
  inatopts = list(), ebirdopts = list(), ecoengineopts = list())
}
\arguments{
  \item{query}{A single name. Either a scientific name or a
  common name. Specify whether a scientific or common name
  in the type parameter. Only scientific names supported
  right now.}

  \item{rank}{Taxonomic rank.}

  \item{from}{Data source to get data from, any combination
  of gbif, bison, or inat}

  \item{type}{Type of name, sci (scientific) or com (common
  name, vernacular)}

  \item{gbifopts}{List of options to pass on to rgbif}

  \item{bisonopts}{List of options to pass on to rbison}

  \item{inatopts}{List of options to pass on to rinat}

  \item{ebirdopts}{List of options to pass on to ebird}

  \item{ecoengineopts}{List of options to pass on to
  ecoengine}
}
\description{
Search on a single species name.
}
\details{
The \code{occ} and \code{occlist} functions are opinionated
wrappers around the rgbif, rbison, rinat, and rebird
packages to allow data access from a single access point.
We take care of making sure you get useful objects out at
the cost of flexibility/options - if you need options you
can use the functions inside each of those packages.
}
\examples{
\dontrun{
# Single data sources
occ(query = 'Accipiter striatus', from = 'gbif')
occ(query = 'Accipiter striatus', from = 'ecoengine')
occ(query = 'Danaus plexippus', from = 'inat')
occ(query = 'Bison bison', from = 'bison')
occ(query = 'Setophaga caerulescens', from = 'ebird', ebirdopts = list(region='US'))
occ(query = 'Spinus tristis', from = 'ebird', ebirdopts = list(method = 'ebirdgeo', lat = 42, lng = -76, dist = 50))

# Many data sources
out <- occ(query = 'Pinus contorta')

## Select individual elements
out$gbif
out$gbif$data

## Coerce to combined data.frame, selects minimal set of columns (name, lat, long)
occ2df(out)

# Many data sources, another example
ebirdopts = list(region = 'US'); gbifopts  =  list(country = 'US')
out <- occ(query = 'Setophaga caerulescens', from = c('gbif','bison','inat','ebird'), gbifopts = gbifopts, ebirdopts = ebirdopts)
occ2df(out)

## Using a bounding box
bounds <- c(38.44047,-125,40.86652,-121.837)
aoibbox <- '-111.31,38.81,-110.57,39.21'
get_inat_obs(query='Mule Deer', bounds = bounds)
occ(query='Danaus plexippus', )

# Pass in many species names
spnames <- c('Accipiter striatus', 'Setophaga caerulescens', 'Spinus tristis')
out <- occ(query=spnames, from='gbif', gbifopts=list(georeferenced=TRUE))
occ2df(out)
}
}

