\name{occdf-class}
\alias{occdf-class}
\title{Coerce to sp object}
\description{
  Coerce to sp object
}
\examples{
\dontrun{
dat <- occ(query='Accipiter striatus', from='gbif')
dat <- occtodf(dat)
as(dat, "SpatialPointsDataFrame")
}
}
\seealso{
  Other res: \code{\link{occDat-class}},
  \code{\link{occDat-class}},
  \code{\link{occDatSpp-class}}, \code{\link{occDf-class}},
  \code{\link{occDfMany-class}},
  \code{\link{occResult-class}},
  \code{\link{occResultList-class}},
  \code{\link{occdfmany-class}}
}

