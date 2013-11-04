\name{occmany_todf}
\alias{occmany_todf}
\title{Coerce elements of output from many occ() calls to a single data.frame}
\usage{
  occmany_todf(x)
}
\arguments{
  \item{x}{A list of objects of class occdat}
}
\value{
  A data.frame
}
\description{
  Coerce elements of output from many occ() calls to a
  single data.frame
}
\examples{
\dontrun{
spp <- c('Danaus plexippus','Accipiter striatus','Pinus contorta')
dat <- lapply(spp, function(x) occ(query=x, from='gbif'))
occmany_todf(dat) # data with compiled metadata
occmany_todf(dat)
}

