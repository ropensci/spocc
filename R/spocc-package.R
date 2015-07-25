#' Currently supported species occurrence databases:
#'
#' \tabular{ll}{
#' Provider \tab Web \cr
#' GBIF \tab \url{http://www.gbif.org/} \cr
#' BISON \tab \url{http://bison.usgs.ornl.gov/} \cr
#' eBird \tab \url{http://ebird.org/content/ebird/} \cr
#' iNaturalist \tab \url{http://www.inaturalist.org/} \cr
#' Berkeley ecoengine \tab \url{https://ecoengine.berkeley.edu/} \cr
#' AntWeb \tab \url{http://www.antweb.org/} \cr
#' VertNet \tab \url{http://vertnet.org/} \cr
#' iDigBio \tab \url{https://www.idigbio.org/}
#' }
#'
#' @importFrom jsonlite toJSON
#' @importFrom utils browseURL head read.csv data
#' @importFrom methods is as
#' @importFrom stats setNames
#' @name spocc-package
#' @aliases spocc
#' @docType package
#' @title R interface to many species occurrence data sources
#' @author Scott Chamberlain \email{myrmecocystus@@gmail.com}
#' @author Karthik Ram \email{karthik.ram@@gmail.com}
#' @author Ted Hart \email{edmund.m.hart@@gmail.com}
#' @keywords package
NULL
