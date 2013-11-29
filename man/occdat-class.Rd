\name{occdat-class}
\alias{occdat}
\alias{occdat-class}
\title{"occdat" class}
\description{
  "occdat" class

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

