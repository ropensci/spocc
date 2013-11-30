\name{occDat-class}
\alias{occDat}
\alias{occDat-class}
\title{"occDat" class}
\description{
  "occDat" class

  Coerce to sp object
}
\examples{
\dontrun{
dat <- occ(query='Accipiter striatus', from='gbif')
spdat <- as(dat, "SpatialPointsDataFrame")
summary(spdat)
bbox(spdat)
plot(spdat)
bubble(obj=spdat, zcol="name", key.space="bottom")
spplot(spdat, names.attr=spdat
}
\seealso{
  Other res: \code{\link{occDf-class}},
  \code{\link{occResult-class}}, \code{\link{occdf-class}},
  \code{\link{occdfmany-class}},
  \code{\link{occdfmany-class}}

  Other res: \code{\link{occDf-class}},
  \code{\link{occResult-class}}, \code{\link{occdf-class}},
  \code{\link{occdfmany-class}},
  \code{\link{occdfmany-class}}
}

