#' Look up options for parameters passed to each source
#'
#' @export
#' 
#' @family queries
#' 
#' @param from (character) Data source to get data from, any combination of 
#' gbif, bison, ebird, idigibio and/or vertnet. Case doesn't matter. 
#' inat is not included here, see that package's help docs.
#' @param where (character) One of console (print to console) or html (opens 
#' help page, if in non-interactive R session, prints help to console).
#' @return Opens up the documentation for the function that is used internally 
#' within the occ function for each source.
#' @details Any of the parameters passed to e.g. [rgbif::occ_data()] from the
#' `rgbif` package can be passed in the associated gbifopts list 
#' in [occ()]
#'
#' Note that the from parameter is lowercased within the function and is 
#' called through match.arg first, so you can match on unique partial 
#' strings too (e.g., 'rv' for 'rvertnet').
#' 
#' For some data sources we don't import the canonical package, but instead
#' have our own internal helper functions and the package in question is
#' not imported, but we do suggest seeing the help for the package on 
#' their parameters:
#' 
#' - **ecoengine**: `?ecoengine::ee_observations`
#' 
#' @examples \dontrun{
#' # opens up documentation for this function
#' occ_options()
#'
#' # Open up documentation for the appropriate search function for each source
#' occ_options('gbif')
#' occ_options('ebird')
#' occ_options('bison')
#' occ_options('idigbio')
#' occ_options('vertnet')
#'
#' # Or open in html version
#' occ_options('bison', 'html')
#' }

occ_options <- function(from = 'gbif', where="console"){
  from <- tolower(from)
  from <- match.arg(from, choices = c('gbif', 'bison', 'ebird', 
                                      'idigbio', 'vertnet'))
  pkgname <- switch(from, gbif = 'rgbif', bison = 'rbison', ebird = 'rebird', 
                    idigbio = 'ridigbio', vertnet = 'rvertnet')
  check_for_package(pkgname)
  fxn <- switch(from, gbif = 'occ_data', bison = 'bison', ebird = 'ebirdregion', 
                idigbio = 'idig_search_records', vertnet = 'vertsearch')
  if (where == "console") {
    res <- tools::Rd_db(pkgname)
    fxnrd <- res[[sprintf('%s.Rd', fxn)]]
    params <- fxnrd[ which(rd_tags(fxnrd) == "\\arguments") ]
    pars <- unlist(sc(sapply(params[[1]], function(x){
      if (!x[[1]] == "\n" && nchar(strtrim(x[[1]])) != 0) {
        paste(x[[1]], gsub("\n", "", paste(unlist(x[[2]]), collapse = " ") ), 
              sep = " - ")
      }
    })))
    cat(sprintf("%s parameters:", fxn), sapply(pars, spocc_wrap, 
                                               indent = 6, width = 80, 
                                               USE.NAMES = FALSE), sep = "\n")
  } else {
    showit <- switch(from,
                     gbif = "?rgbif::occ_data",
                     bison = "?rbison::bison",
                     ebird = "?rebird::ebirdregion",
                     idigbio = "?ridigbio::idig_search_records",
                     vertnet = "?rvertnet::vertsearch")
    eval(parse(text = showit))
  }
}

rd_tags <- function(Rd){
  res <- sapply(Rd, attr, "Rd_tag")
  if (!length(res))
    res <- character()
  res
}
