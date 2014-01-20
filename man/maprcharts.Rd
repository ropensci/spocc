\name{maprcharts}
\alias{maprcharts}
\title{Make an interactive map to view in the browser}
\usage{
maprcharts(data, popup = TRUE, map_provider = "MapQuestOpen.OSM",
  map_zoom = 3, height = 600, width = 870, palette_color = "Blues",
  centerview = c(30, -73.9), fullscreen = TRUE, path = NULL)
}
\arguments{
  \item{data}{A data.frame, with any number of columns, but
  with at least the following: name (the taxonomic name),
  latitude (in dec. deg.), longitude (in dec. deg.)}

  \item{popup}{If TRUE (default) popup tooltips are created
  for each point with metadta for that point.}

  \item{map_provider}{Base map to use. See \code{basemaps}.
  See details.}

  \item{map_zoom}{Map zoom, 1 being most zoomed in. See
  details.}

  \item{height}{Height of map}

  \item{width}{Width of map}

  \item{palette_color}{Color brewer color palette. See
  \code{palettes}}

  \item{centerview}{Lat/long position to center map}

  \item{fullscreen}{If TRUE, full screen option avail, if
  not, not avail.}

  \item{path}{Specify a path to save an html file of your
  map. You can open this in your browser to view it. If
  left as NULL (the default) the map opens up in your
  default browser, or if you have a newer version of
  RStudio open in RStudio Viewer pane.}
}
\description{
Make an interactive map to view in the browser
}
\details{
NOTE that with some map_provider options you will have no
map layer show up at first. This may be because there is no
map at that particular zoom level. Just zoom in or out to
see the map.
}
\examples{
\dontrun{
library(rCharts)
spp <- c('Danaus plexippus','Accipiter striatus','Pinus contorta')
dat <- occ(query=spp, from='gbif', gbifopts=list(georeferenced=TRUE))
data <- occ2df(dat, 'data')
maprcharts(data=data)

# An example with more species, a different base map, and different color palette
spp <- c('Danaus plexippus','Accipiter striatus','Pinus contorta','Puma concolor','Ursus americanus','Gymnogyps californianus')
dat <- occlist(query=spp, from='gbif', gbifopts=list(georeferenced=TRUE))
data <- occtodfspp(dat, 'data')
maprcharts(data, map_provider="Acetate.terrain", palette_color="OrangeRed")
}
}

