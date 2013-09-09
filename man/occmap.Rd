\name{occmap}
\alias{occmap}
\title{Make a map of species occurrence data.}
\usage{
  occmap(input = NULL, mapdatabase = "world", region = ".",
    geom = geom_point, jitter = NULL, customize = NULL)
}
\description{
  Make a map of species occurrence data.
}
\examples{
\dontrun{
# Point map, using output from occurrencelist, example 1
out <- occ('Accipiter erythronemius', from = c('rgbif','bison'), maxresults = 100)
occmap(out)
}
}

