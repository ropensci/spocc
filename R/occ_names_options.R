#' Look up options for parameters passed to each source for occ_names function
#'
#' @export
#'
#' @param from (character) Data source to get data from, any combination of gbif, bison,
#' and/or ecoengine. Case doesn't matter.
#' @param where (character) One of console (print to console) or html (opens help page, if in
#' non-interactive R session, prints help to console).
#'
#' @return Opens up the documentation for the function that is used internally within
#' the occ function for each source.
#' @details Any of the parameters passed to e.g. \code{\link[rgbif]{name_lookup}} from the
#' \code{rgbif} package can be passed in the associated gbifopts list in \code{\link[spocc]{occ}}.
#'
#' Note that the from parameter is lowercased within the function and is called through
#' \code{match.arg} first, so you can match on unique partial strings too (e.g., 'e' for
#' 'ecoengine').
#' @examples \dontrun{
#' # opens up documentation for this function
#' occ_names_options()
#'
#' # Open up documentation for the appropriate search function for each source
#' occ_names_options('gbif')
#' occ_names_options('ecoengine')
#' occ_names_options('bison')
#'
#' # Or open in html version
#' occ_names_options('bison', 'html')
#' }

occ_names_options <- function(from = 'gbif', where="console"){
  from <- tolower(from)
  from <- match.arg(from, choices=c('gbif','bison','ecoengine'))
  pkgname <- switch(from, gbif='rgbif', bison='rbison', ecoengine='ecoengine')
  check_for_package(pkgname)
  fxn <- switch(from, gbif='name_lookup', bison='bison_tax', ecoengine='ee_search')
  if(where == "console"){
    res <- tools::Rd_db(pkgname)
    fxnrd <- res[[sprintf('%s.Rd', fxn)]]
    params <- fxnrd[ which(rd_tags(fxnrd) == "\\arguments") ]
    pars <- unlist(sc(sapply(params[[1]], function(x){
      if(!x[[1]] == "\n") paste(x[[1]], gsub("\n", "", paste(unlist(x[[2]]), collapse = " ") ), sep = " - ")
    })))
    cat(sprintf("%s parameters:", fxn), sapply(pars, spocc_wrap, indent=6, width=80, USE.NAMES = FALSE), sep = "\n")
  } else {
    showit <- switch(from,
                     gbif = "?rgbif::name_lookup",
                     bison = "?rbison::bison_tax",
                     ecoengine = "?ecoengine::ee_search")
    eval(parse(text = showit))
  }
}
