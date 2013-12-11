\name{occ2df}
\alias{occ2df}
\title{Combine results from occ calls to a single data.frame}
\usage{
occ2df(obj, what = "data")
}
\arguments{
  \item{obj}{Input from occ}

  \item{what}{One of data (default) or all (with metadata)}
}
\description{
Combine results from occ calls to a single data.frame
}
\examples{
\dontrun{
spnames <- c('Accipiter striatus', 'Setophaga caerulescens', 'Spinus tristis')
out <- occ(query=spnames, from='gbif', gbifopts=list(georeferenced=TRUE))
occ2df(out)
}
}

