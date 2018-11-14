#' @title Interface to many species occurrence data sources
#' 
#' @description A programmatic interface to many species occurrence data 
#' sources, including GBIF, USGS's BISON, iNaturalist, Berkeley Ecoinformatics 
#' Engine, eBird, iDigBio, VertNet, OBIS, and ALA. Includes 
#' functionality for retrieving species occurrence data, and 
#' combining that data.
#' 
#' @section Package API:
#' 
#' The main function to use is [occ()] - a single interface to 
#' many species occurrence databases (see below for a list). 
#' 
#' Other functions include:
#' 
#' - [occ2df()] - Combine results from `occ` into a 
#'  data.frame
#' - [fixnames()] - Change names to be the same for each taxon
#' - [wkt_vis()] - Visualize WKT strings (used to define 
#'  geometry based searches for some data sources) in an interactive map
#' 
#' @section Currently supported species occurrence data sources:
#'
#' \tabular{ll}{
#' Provider \tab Web \cr
#' GBIF \tab <http://www.gbif.org/> \cr
#' BISON \tab <https://bison.usgs.gov/> \cr
#' eBird \tab <http://ebird.org/content/ebird/> \cr
#' iNaturalist \tab <http://www.inaturalist.org/> \cr
#' Berkeley ecoengine \tab <https://ecoengine.berkeley.edu/> \cr
#' VertNet \tab <http://vertnet.org/> \cr
#' iDigBio \tab <https://www.idigbio.org/> \cr
#' OBIS \tab <http://www.iobis.org/> \cr
#' ALA \tab <http://www.ala.org.au/>
#' }
#' 
#' @section Duplicates:
#' 
#' See [spocc_duplicates()] for more.
#' 
#' @section Clean data:
#' 
#' All data cleaning functionality is in a new package: `scrubr` 
#' (<https://github.com/ropensci/scrubr>).
#' On CRAN: <https://cran.r-project.org/package=scrubr>. 
#' See also package 
#' <https://cran.r-project.org/package=CoordinateCleaner>
#' 
#' @section Make maps:
#' 
#' All mapping functionality is now in a separate package: `mapr``
#' (<https://github.com/ropensci/mapr>) (formerly known as `spoccutils`).
#' On CRAN: <https://cran.r-project.org/package=mapr>
#'
#' @importFrom jsonlite toJSON
#' @importFrom utils browseURL head read.csv data setTxtProgressBar 
#' txtProgressBar
#' @importFrom data.table rbindlist setDF
#' @importFrom tibble as_data_frame data_frame
#' @importFrom lubridate now ymd_hms ymd_hm ydm_hm ymd as_date
#' @importFrom rgbif occ_data occ_get name_lookup
#' @importFrom rebird ebirdregion ebirdgeo
#' @importFrom rbison bison_solr bison bison_tax
#' @importFrom rvertnet vertsearch
#' @importFrom ridigbio idig_search_records idig_view_records
#' @importFrom whisker whisker.render
#' @name spocc-package
#' @aliases spocc
#' @docType package
#' @author Scott Chamberlain \email{myrmecocystus@@gmail.com}
#' @keywords package
NULL
