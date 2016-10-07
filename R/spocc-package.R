#' @title Interface to many species occurrence data sources
#' 
#' @description A programmatic interface to many species occurrence data sources,
#' including GBIF, USGS's BISON, iNaturalist, Berkeley Ecoinformatics Engine, 
#' eBird, AntWeb, and iDigBio. Includes functionality for retrieving species 
#' occurrence data, and combining that data.
#' 
#' @section Package API:
#' 
#' The main function to use is \code{\link{occ}} - a single interface to many species 
#' occurrence databases (see below for a list). 
#' 
#' Other functions include:
#' \itemize{
#'  \item \code{\link{occ2df}} - Combine results from \code{occ} into a data.frame
#'  \item \code{\link{fixnames}} - Change names to be the same for each taxon
#'  \item \code{\link{wkt_vis}} - Visualize WKT strings (used to define geometry based
#'  searches for some data sources) in an interactive map
#' }
#' 
#' @section Currently supported species occurrence databases:
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
#' @section Duplicates:
#' 
#' See \code{\link{spocc_duplicates}} for more.
#' 
#' @section Clean data:
#' 
#' All data cleaning functionality is in a new package: \code{scrubr} 
#' (\url{https://github.com/ropenscilabs/scrubr}).
#' On CRAN: \url{https://cran.r-project.org/package=scrubr}
#' 
#' @section Make maps:
#' 
#' All mapping functionality is now in a separate package: \code{mapr} 
#' (\url{https://github.com/ropensci/mapr}) (formerly known as `spoccutils`).
#' On CRAN: \url{https://cran.r-project.org/package=mapr}
#'
#' @importFrom jsonlite toJSON
#' @importFrom utils browseURL head read.csv data setTxtProgressBar txtProgressBar
#' @importFrom data.table rbindlist setDF
#' @importFrom tibble as_data_frame data_frame
#' @importFrom lubridate now ymd_hms ymd_hm ydm_hm ymd as_date
#' @importFrom rgbif occ_data occ_get name_lookup
#' @importFrom rebird ebirdregion ebirdgeo
#' @importFrom rbison bison_solr bison bison_tax
#' @importFrom rvertnet vertsearch
#' @importFrom ridigbio idig_search_records idig_view_records
#' @name spocc-package
#' @aliases spocc
#' @docType package
#' @author Scott Chamberlain \email{myrmecocystus@@gmail.com}
#' @author Karthik Ram \email{karthik.ram@@gmail.com}
#' @author Ted Hart \email{edmund.m.hart@@gmail.com}
#' @keywords package
NULL
