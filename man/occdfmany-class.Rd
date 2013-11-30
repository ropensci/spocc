\name{occdfmany-class}
\alias{occdfmany-class}
\title{Coerce to sp object}
\description{
  Coerce to sp object
}
\examples{
\dontrun{
spp <- c('Danaus plexippus','Accipiter striatus','Pinus contorta')
dat <- lapply(spp, function(x) occ(query=x, from='gbif', gbifopts=list(georeferenced=TRUE)))
dfmany <- occmanytodf(dat)
spdat <- as(dfmany, "SpatialPointsDataFrame")
spdat
}
\seealso{
  Other res: \code{\link{occDat-class}},
  \code{\link{occDat-class}},
  \code{\link{occDatSpp-class}}, \code{\link{occDf-class}},
  \code{\link{occDfMany-class}},
  \code{\link{occResult-class}},
  \code{\link{occResultList-class}},
  \code{\link{occdf-class}}
}

