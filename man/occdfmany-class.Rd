\name{occdfmany-class}
\alias{occdfmany}
\alias{occdfmany-class}
\title{"occdfmany" class}
\description{
  "occdfmany" class

  Coerce to sp object
}
\examples{
\dontrun{
spp <- c('Danaus plexippus','Accipiter striatus','Pinus contorta')
dat <- lapply(spp, function(x) occ(query=x, from='gbif', gbifopts=list(georeferenced=TRUE)))
dfmany <- occmany_todf(dat)
spdat <- as(dfmany, "SpatialPointsDataFrame")
spdat
}
\seealso{
  Other res: \code{\link{occDat-class}},
  \code{\link{occDat-class}}, \code{\link{occDf-class}},
  \code{\link{occResult-class}}, \code{\link{occdf-class}}

  Other res: \code{\link{occDat-class}},
  \code{\link{occDat-class}}, \code{\link{occDf-class}},
  \code{\link{occResult-class}}, \code{\link{occdf-class}}
}

