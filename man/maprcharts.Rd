\name{maprcharts}
\alias{maprcharts}
\title{Make an interactive map to view in the browser}
\usage{
  maprcharts(data, popup = TRUE,
    map_provider = "MapQuestOpen.OSM", map_zoom = 2,
    height = 600, width = 870, palette_color = "Blues",
    centerview = c(30, -73.9), fullscreen = TRUE)
}
\arguments{
  \item{data}{A data.frame, with any number of columns, but
  with at least the following: name (the taxonomic name),
  latitude (in dec. deg.), longitude (in dec. deg.)}

  \item{popup}{If TRUE (default) popup tooltips are created
  for each point with metadta for that point.}

  \item{map_provider}{Base map to use. See \code{basemaps}}

  \item{map_zoom}{Map zoom, 1 being most zoomed in}

  \item{height}{Height of map}

  \item{width}{Width of map}

  \item{palette_color}{Color brewer color palette. See
  \code{palettes}}

  \item{centerview}{Lat/long position to center map}

  \item{fullscreen}{If TRUE, full screen option avail, if
  not, not avail.}
}
\description{
  Make an interactive map to view in the browser
}
\examples{
\dontrun{
library(rCharts)
spp <- c('Danaus plexippus','Accipiter striatus','Pinus contorta')
dat <- lapply(spp, function(x) occ(query=x, from='gbif'))
dat <- occmany_todf(dat)
}

