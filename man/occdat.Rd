\name{print.occdat}
\alias{plot.occdat}
\alias{print.occdat}
\title{Print brief summary of occ function output}
\usage{
\method{print}{occdat}(x, ...)

\method{plot}{occdat}(x, ...)
}
\arguments{
  \item{x}{Input object from occ function, of class occdat}

  \item{...}{Further args passed on to points fxn}
}
\description{
Print brief summary of occ function output

Plot occ function output on a map (uses base plots)
}
\examples{
\dontrun{
spnames <- c('Accipiter striatus', 'Setophaga caerulescens', 'Spinus tristis')
out <- occ(query = spnames, from = 'gbif', gbifopts = list(georeferenced=TRUE))
print(out)
out # gives the same thing

# you can still drill down into the data easily
out$gbif$meta
out$gbif$data
}
\dontrun{
spnames <- c('Accipiter striatus', 'Setophaga caerulescens', 'Spinus tristis')
out <- occ(query=spnames, from='gbif', gbifopts=list(georeferenced=TRUE))
plot(out, cex=1, pch=10)
}
}

