#' A note about duplicate occurrence records
#' 
#' @description
#' BEWARE: spocc provides you a nice interface to many data providers for 
#' species occurrence data. However, in cases where you request data from 
#' GBIF *in addition* to other data sources, there could be duplicate records. 
#' This is because GBIF is, to use an ecology  analogy, a top predator, and 
#' pulls in data from lower nodes in the food chain. For example, iNaturalist 
#' provides data to GBIF, so if you search for occurrence records for 
#' *Pinus contorta* from iNaturalist and GBIF, you could get, for example, 
#' 20 of the same records. 
#' 
#' We think a single R interface to many occurrence record providers 
#' will provide a consistent way to work with occurrence data, making 
#' analyses and vizualizations more repeatable across providers.
#' 
#' For cleaning data, see packages `scrubr` 
#' (<https://cran.r-project.org/package=scrubr>) and `CoordinateCleaner` 
#' (<https://cran.r-project.org/package=CoordinateCleaner>)
#' 
#' Do get in touch with us if you have concerns, have ideas for eliminating 
#' duplicates
#'
#' @name spocc_duplicates
NULL
