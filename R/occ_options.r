#' Look up options for parameters passed to each source
#' 
#' @param from (character) Data source to get data from, any combination of gbif, bison,
#' inat, ebird, AntWeb, and/or ecoengine
#' @return Opens up the documentation for the function that is used internally within 
#' the occ function for each source.
#' @details Any of the parameters passed to e.g. occ_search() from the rgbif package 
#' can be passed in the associated gbifopts list in occ(). 
#' 
#' Note that the from parameter is lowercased within the function and is called through
#' match.arg first, so you can match on unique partial strings too (e.g., 'e' for 'ecoengine').
#' @export
#' @examples
#' occ_options()
#' occ_options('ecoengine')
#' occ_options('AntWeb')

occ_options <- function(from = 'gbif'){
  from <- tolower(from)
  from <- match.arg(from, choices=c('gbif','bison','inat','ebird','ecoengine','antweb'))
  showit <- switch(from,
                   gbif = "?rgbif::occ_search",
                   bison = "?rbison::bison",
                   inat = "?rinat::get_inat_obs",
                   ebird = "?rebird::ebirdregion",
                   ecoengine = "?ecoengine::ee_observations",
                   antweb = "?AntWeb::aw_data")
  eval(parse(text = showit))
}