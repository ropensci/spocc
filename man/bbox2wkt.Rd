\name{bbox2wkt}
\alias{bbox2wkt}
\title{Converts a bounding box to a Well Known Text polygon}
\usage{
bbox2wkt(minx = NA, miny = NA, maxx = NA, maxy = NA, bbox = NULL)
}
\arguments{
  \item{minx}{Minimum x value, or the most western
  longitude}

  \item{miny}{Minimum y value, or the most southern
  latitude}

  \item{maxx}{Maximum x value, or the most eastern
  longitude}

  \item{maxy}{Maximum y value, or the most northern
  latitude}

  \item{bbox}{A vector of length 4, with the elements:
  minx, miny, maxx, maxy}
}
\value{
An object of class charactere, a Well Known Text string of
the form 'POLYGON((minx miny, maxx miny, maxx maxy, minx
maxy, minx miny))'
}
\description{
Converts a bounding box to a Well Known Text polygon
}
\examples{
library(rgeos)

# Pass in a vector of length 4 with all values
mm <- bbox2wkt(bbox=c(38.4,-125.0,40.9,-121.8))
plot(readWKT(mm))

# Or pass in each value separately
mm <- bbox2wkt(minx=38.4, miny=-125.0, maxx=40.9, maxy=-121.8)
plot(readWKT(mm))
}

