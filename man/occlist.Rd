\name{occlist}
\alias{occlist}
\title{Search for species occurrence data across many data sources.}
\usage{
  occlist(query = NULL, rank = "species",
    from = c("gbif", "bison", "inat", "npn", "ebird"),
    type = "sci", gbifopts = list(), bisonopts = list(),
    inatopts = list(), npnopts = list(),
    ebirdopts = list())
}
\arguments{
  \item{query}{Either a single name, or a vetor of names.
  Either a scientific name or a common name. Specify
  whether a scientific or common name in the type
  parameter. Only scientific names supported right now.}

  \item{rank}{Taxonomic rank.}

  \item{from}{Data source to get data from, any combination
  of gbif, bison, or inat}

  \item{type}{Type of name, sci (scientific) or com (common
  name, vernacular)}

  \item{gbifopts}{List of options to pass on to rgbif}

  \item{bisonopts}{List of options to pass on to rbison}

  \item{inatopts}{List of options to pass on to rinat}

  \item{npnopts}{List of options to pass on to rnpn}

  \item{ebirdopts}{List of options to pass on to ebird}
}
\description{
  Search on a vector or list of species names.
}
\details{
  The \code{occ} and \code{occlist} functions are
  opinionated wrappers around the rgbif, rbison, rinat, and
  rebird packages to allow data access from a single access
  point. We take care of making sure you get useful objects
  out at the cost of flexibility/options - if you need
  options you can use the functions inside each of those
  packages.
}
\examples{
\dontrun{
# Data from a single source
spnames <- c('Accipiter striatus', 'Setophaga caerulescens', 'Spinus tristis')
occlist(query=spnames, from='gbif', gbifopts=list(georeferenced=TRUE))

# Data from many sources
spnames <- c('Accipiter striatus', 'Setophaga caerulescens', 'Spinus tristis')
occlist(query=spnames, from=c('gbif','bison'), gbifopts=list(georeferenced=TRUE))
}
}

