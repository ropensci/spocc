\name{occmany_todf}
\alias{occmany_todf}
\title{Coerce elements of output from many occ() calls to a single data.frame}
\usage{
  occmany_todf(...)
}
\arguments{
  \item{...}{A list of objects, or any number of objects
  separated by commas, all of class occdat.}
}
\value{
  An object of class occdfmany, with a metadata (meta) slot
  and a data slot. Includes metadata from all input occdat
  objects as a list in the meta slot, and a combined
  data.frame from all inputs.
}
\description{
  Coerce elements of output from many occ() calls to a
  single data.frame
}
\examples{
\dontrun{
# Pass in a list of occdat objects
spp <- c('Danaus plexippus','Accipiter striatus','Pinus contorta')
dat <- lapply(spp, function(x) occ(query=x, from='gbif'))
occmany_todf(dat) # data with compiled metadata
occmany_todf(dat)
}

