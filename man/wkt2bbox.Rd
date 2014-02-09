\name{wkt2bbox}
\alias{wkt2bbox}
\title{Converts a Well Known Text polygon to a bounding box}
\usage{
wkt2bbox(wkt = NULL)
}
\arguments{
  \item{wkt}{A Well Known Text object.}
}
\value{
A vector of length 4, like c(minx, miny, maxx, maxy).
}
\description{
Converts a Well Known Text polygon to a bounding box
}
\examples{
library(rgeos)
wkt <- "POLYGON((38.4 -125,40.9 -125,40.9 -121.8,38.4 -121.8,38.4 -125))"
wkt2bbox(wkt)
}
\keyword{internal}

