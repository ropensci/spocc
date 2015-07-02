#' Look up options for parameters passed to each source
#'
#' @param from (character) Data source to get data from, any combination of gbif, bison,
#' ebird, AntWeb, and/or ecoengine. Case doesn't matter. inat is not included here,
#' see that package's help docs.
#' @param where (character) One of console (print to console) or html (opens help page, if in
#' non-interactive R session, prints help to console).
#' @return Opens up the documentation for the function that is used internally within
#' the occ function for each source.
#' @details Any of the parameters passed to e.g. \code{\link[rgbif]{occ_search}} from the
#' \code{rgbif} package can be passed in the associated gbifopts list in \code{\link[spocc]{occ}}.
#'
#' Note that the from parameter is lowercased within the function and is called through
#' match.arg first, so you can match on unique partial strings too (e.g., 'e' for 'ecoengine').
#' @export
#' @examples \dontrun{
#' # opens up documentation for this function
#' occ_options()
#'
#' # Open up documentation for the appropriate search function for each source
#' occ_options('gbif')
#' occ_options('ecoengine')
#' occ_options('AntWeb')
#' occ_options('antweb')
#' occ_options('ebird')
#' occ_options('bison')
#'
#' # Or open in html version
#' occ_options('bison', 'html')
#' }

occ_options <- function(from = 'gbif', where="console"){
  from <- tolower(from)
  from <- match.arg(from, choices=c('gbif','bison','ebird','ecoengine','antweb'))
  pkgname <- switch(from, gbif='rgbif', bison='rbison', ebird='rebird', ecoengine='ecoengine', antweb='AntWeb')
  fxn <- switch(from, gbif='occ_search', bison='bison', ebird='ebirdregion', ecoengine='ee_observations', antweb='aw_data')
  if(where == "console"){
    res <- tools::Rd_db(pkgname)
    fxnrd <- res[[sprintf('%s.Rd', fxn)]]
    params <- fxnrd[ which(rd_tags(fxnrd) == "\\arguments") ]
    pars <- unlist(sc(sapply(params[[1]], function(x){
      if(!x[[1]] == "\n" && nchar(strtrim(x[[1]])) != 0) paste(x[[1]], gsub("\n", "", paste(unlist(x[[2]]), collapse = " ") ), sep = " - ")
    })))
    cat(sprintf("%s parameters:", fxn), sapply(pars, spocc_wrap, indent=6, width=80, USE.NAMES = FALSE), sep = "\n")
  } else {
    showit <- switch(from,
                     gbif = "?rgbif::occ_search",
                     bison = "?rbison::bison",
                     ebird = "?rebird::ebirdregion",
                     ecoengine = "?ecoengine::ee_observations",
                     antweb = "?AntWeb::aw_data")
    eval(parse(text = showit))
  }
}

rd_tags <- function(Rd){
  res <- sapply(Rd, attr, "Rd_tag")
  if (!length(res))
    res <- character()
  res
}
