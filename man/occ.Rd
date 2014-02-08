\name{occ}
\alias{occ}
\title{Search for species occurrence data across many data sources.}
\usage{
occ(query = NULL, from = "gbif", limit = 25, geometry = NULL,
  rank = "species", type = "sci", gbifopts = list(), bisonopts = list(),
  inatopts = list(), ebirdopts = list(), ecoengineopts = list())
}
\arguments{
  \item{query}{(character) One to many names. Either a
  scientific name or a common name. Specify whether a
  scientific or common name in the type parameter. Only
  scientific names supported right now.}

  \item{from}{(character) Data source to get data from, any
  combination of gbif, bison, inat, ebird, and/or
  ecoengine}

  \item{limit}{(numeric) Number of records to return. This
  is passed across all sources. To specify different limits
  for each source, use the options for each source.}

  \item{geometry}{(character) Searches for occurrences
  inside a polygon described in Well Known Text (WKT)
  format. A WKT shape written as 'POLYGON((30.1 10.1, 20,
  20 40, 40 40, 30.1 10.1))' would be queried as is, i.e.
  http://bit.ly/HwUSif. See Details for more examples of
  WKT objects.}

  \item{rank}{(character) Taxonomic rank. Not used right
  now.}

  \item{type}{(character) Type of name, sci (scientific) or
  com (common name, vernacular). Not used right now.}

  \item{gbifopts}{(list) List of options to pass on to
  rgbif}

  \item{bisonopts}{(list) List of options to pass on to
  rbison}

  \item{inatopts}{(list) List of options to pass on to
  rinat}

  \item{ebirdopts}{(list) List of options to pass on to
  ebird}

  \item{ecoengineopts}{(list) List of options to pass on to
  ecoengine}
}
\description{
Search on a single species name. When searching ecoengine,
you can leave the page argument blank to get a single page.
Otherwise use page ranges or simply "all" to request all
available pages. Note however that this may hang your call
if the request is simply too large.
}
\details{
The \code{occ} function is an opinionated wrapper around
the rgbif, rbison, rinat, rebird, and ecoengine packages to
allow data access from a single access point. We take care
of making sure you get useful objects out at the cost of
flexibility/options - although you can still set options
for each of the packages via the gbifopts, bisonopts,
inatopts, ebirdopts, and ecoengineopts parameters.

WKT objects are strings of pairs of lat/long coordinates
that define a shape. Many classes of shapes are supported,
including POLYGON, POINT, and XXXX. Within each defined
shape define all vertices of the shape with a coordinate
like 30.1 10.1, the first of which is the latitude, the
second the longitude.

Examples of valid WKT objects: \itemize{ \item
'POLYGON((30.1 10.1, 10 20, 20 60, 60 60, 30.1 10.1))'
\item 'POINT((30.1 10.1))' \item 'LINESTRING(3 4,10 50,20
25)' \item 'MULTIPOINT((3.5 5.6),(4.8 10.5))")' \item
'MULTILINESTRING((3 4,10 50,20 25),(-5 -8,-10 -8,-15 -4))'
\item 'MULTIPOLYGON(((1 1,5 1,5 5,1 5,1 1),(2 2,2 3,3 3,3
2,2 2)),((6 3,9 2,9 4,6 3)))' \item
'GEOMETRYCOLLECTION(POINT(4 6),LINESTRING(4 6,7 10))' }
}
\examples{
\dontrun{
# Single data sources
occ(query = 'Accipiter striatus', from = 'gbif')
occ(query = 'Accipiter striatus', from = 'ecoengine')
occ(query = 'Danaus plexippus', from = 'inat')
occ(query = 'Bison bison', from = 'bison')
occ(query = 'Setophaga caerulescens', from = 'ebird', ebirdopts = list(region='US'))
occ(query = 'Spinus tristis', from = 'ebird', ebirdopts =
   list(method = 'ebirdgeo', lat = 42, lng = -76, dist = 50))

# Many data sources
out <- occ(query = 'Pinus contorta', from=c('gbif','inat'))

## Select individual elements
out$gbif
out$gbif$data

## Coerce to combined data.frame, selects minimal set of columns (name, lat, long)
occ2df(out)

# Pass in limit parameter to all sources. This limits the number of occurrences
# returned to 10, in this example, for all sources, in this case gbif and inat.
occ(query='Pinus contorta', from=c('gbif','inat'), limit=10)

# Pass in geometry parameter to all sources. This constraints the search to the
# specified polygon for all sources, gbif and bison in this example.
occ(query='Accipiter striatus', from='gbif',
   geometry='POLYGON((30.1 10.1, 10 20, 20 60, 60 60, 30.1 10.1))')
occ(query='Helianthus annuus', from='bison',
   geometry='POLYGON((-111.06 38.84, -110.80 39.37, -110.20 39.17, -110.20 38.90, -110.63 38.67, -111.06 38.84))')

# Many data sources, another example
ebirdopts = list(region = 'US'); gbifopts  =  list(country = 'US')
out <- occ(query = 'Setophaga caerulescens', from = c('gbif','inat','bison','ebird'),
gbifopts = gbifopts, ebirdopts = ebirdopts)
occ2df(out)

## Using a bounding box
bounds <- c(38.44047,-125,40.86652,-121.837)
head(occ(query = 'Danaus plexippus', from="inat", inatopts=list(bounds=bounds))$inat$data)

# Pass in many species names
spnames <- c('Accipiter striatus', 'Setophaga caerulescens', 'Spinus tristis')
out <- occ(query = spnames, from = 'gbif', gbifopts = list(georeferenced = TRUE))
head(occ2df(out))
}
}

