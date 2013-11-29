\name{occ_todf}
\alias{occ_todf}
\title{Coerce elements of output from a single occ() call to a single data.frame}
\usage{
  occ_todf(x)
}
\arguments{
  \item{x}{An object of class occdat}
}
\value{
  An object of class occdf, including metadata from input
  occdat object, and a combined data.frame from different
  sources. If a single data sources was called in the
  \code{occ} call, the same data.frame is returned.
}
\description{
  Coerce elements of output from a single occ() call to a
  single data.frame
}

