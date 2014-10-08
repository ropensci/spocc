#' Search for species names across many data sources.
#' 
#' @export
#' 
#' @param query (character) One to many names. Either a scientific name or a common name.
#' Specify whether a scientific or common name in the type parameter.
#' Only scientific names supported right now.
#' @param from (character) Data source to get data from, any combination of gbif, bison,
#' inat, ebird, and/or ecoengine
#' @param limit (numeric) Number of records to return. This is passed across all sources.
#' To specify different limits for each source, use the options for each source (gbifopts, 
#' bisonopts, inatopts, ebirdopts, ecoengineopts, and antwebopts). See Details for more. 
#' Default: 500 for each source. BEWARE: if you have a lot of species to query for (e.g., 
#' n = 10), that's 10 * 500 = 5000, which can take a while to collect. So, when you first query,
#' set the limit to something smallish so that you can get a result quickly, then do more as 
#' needed.
#' @param rank (character) Taxonomic rank. Not used right now.
#' @param callopts Options passed on to \code{\link[httr]{GET}}, e.g., for debugging curl calls, 
#' setting timeouts, etc. This parameter is ignored for sources: antweb, inat.
#' @param gbifopts (list) List of named options to pass on to \code{\link[rgbif]{name_lookup}}. See
#' also \code{\link[spocc]{occ_names_options}}. 
#' @param bisonopts (list) List of named options to pass on to \code{\link[rbison]{bison}}. See 
#' also \code{\link[spocc]{occ_names_options}}.
#' @param inatopts (list) List of named options to pass on to \code{\link[rinat]{get_inat_obs}}. 
#' See also \code{\link[spocc]{occ_names_options}}.
#' @param ecoengineopts (list) List of named options to pass on to 
#' \code{\link[ecoengine]{ee_observations}}. See also \code{\link[spocc]{occ_names_options}}.
#' @param antwebopts (list) List of named options to pass on to \code{\link[AntWeb]{aw_data}}. See
#' also \code{\link[spocc]{occ_names_options}}.
#' 
#' @examples \dontrun{
#' # Single data sources
#' res <- occ_names(query = 'Accipiter striatus', from = 'gbif')
#' head(res$gbif$data)
#' }

occ_names <- function(query = NULL, from = "gbif", limit = 100, rank = "species",
  callopts=list(), gbifopts = list(), bisonopts = list(), inatopts = list(),
  ecoengineopts = list(), antwebopts = list())
{ 
  sources <- match.arg(from, choices = c("gbif", "bison", "inat", "ecoengine", "antweb"), 
                       several.ok = TRUE)
  
  tmp <- lapply(query, loopfun, y=limit, w=callopts, op=list(
    gbi=gbifopts, bis=bisonopts, inat=inatopts, eco=ecoengineopts, ant=antwebopts)
  )
  
  gbif_sp <- getsplist(tmp, "gbif", gbifopts)
  bison_sp <- getsplist(tmp, "bison", bisonopts)
  inat_sp <- getsplist(tmp, "inat", inatopts)
  ecoengine_sp <- getsplist(tmp, "ecoengine", ecoengineopts)
  antweb_sp <- getsplist(tmp, "antweb", ecoengineopts)
  structure(list(gbif = gbif_sp, bison = bison_sp, inat = inat_sp,
            ecoengine = ecoengine_sp, antweb = antweb_sp), class="occnames")
}

loopfun <- function(x, y, w, op) {
  # x = query; y = limit; w = callopts; op=source options
  gbif_res <- names_gbif(sources, x, y, w, op$gbi)
  bison_res <- names_bison(sources, x, y, w, op$bis)
  inat_res <- names_inat(sources, x, y, w, op$inat)
  ecoengine_res <- names_ecoengine(sources, x, y, w, op$eco)
  antweb_res <- names_antweb(sources, x, y, w, op$ant)
  list(gbif = gbif_res, bison = bison_res, inat = inat_res,
       ecoengine = ecoengine_res, antweb = antweb_res)
}

getsplist <- function(tmp, srce, opts) {
  tt <- lapply(tmp, function(x) x[[srce]]$data)
  names(tt) <- gsub("\\s", "_", query)
  optstmp <- tmp[[1]][[srce]]$opts
  
  if (any(grepl(srce, sources))) {
    structure(list(meta = list(source = srce, time = tmp[[1]][[srce]]$time,
                               found = tmp[[1]][[srce]]$found, returned = nrow(tmp[[1]][[srce]]$data), 
                               opts = optstmp), data = tt), class="occnamesind")
  } else {
    structure(list(meta = list(source = srce, time = NULL, found = NULL, returned = NULL, 
                               opts = NULL), data = tt), class="occnamesind")
  }
}

#' @export
#' @rdname spocc_objects
print.occnames <- function(x, ...) {
  rows <- lapply(x, function(y) vapply(y$data, nrow, numeric(1)))
  perspp <- lapply(rows, function(z) c(sum(z), length(z)))
  cat("Summary of results - occurrences found for:", "\n")
  cat(" gbif  :", perspp$gbif[1], "records across", perspp$gbif[2], "species",
      "\n")
  cat(" bison : ", perspp$bison[1], "records across", perspp$bison[2], "species",
      "\n")
  cat(" inat  : ", perspp$inat[1], "records across", perspp$inat[2], "species",
      "\n")
  cat(" ebird : ", perspp$ebird[1], "records across", perspp$ebird[2], "species",
      "\n")
  cat(" ecoengine : ", perspp$ecoengine[1], "records across", perspp$ecoengine[2],
      "species", "\n")
  cat(" antweb : ", perspp$antweb[1], "records across", perspp$antweb[2],
      "species", "\n")
}

#' @noRd
names_gbif <- function(sources, query, limit, callopts, opts){
  if (any(grepl("gbif", sources))) {
    if(is.null(query)){ emptylist(opts) } else {
      time <- now()
      opts$query <- query
      if(!'limit' %in% names(opts)) opts$limit <- limit
      opts$callopts <- callopts
      out <- do.call(name_lookup, opts)
      if(class(out) == "character"|| class(out$data) == "character") { emptylist(opts) } else {
        dat <- out$data
        dat$prov <- rep("gbif", nrow(dat))
        list(time = time, found = out$meta$count, data = dat, opts = opts)
      }
    }
  } else { emptylist(opts) }
}

#' @noRd
names_bison <- function(sources, query, limit, callopts, opts){
  if (any(grepl("gbif", sources))) {
    emptylist(opts)
  } else { emptylist(opts) }
}

#' @noRd
names_inat <- function(sources, query, limit, callopts, opts){
  if (any(grepl("gbif", sources))) {
    emptylist(opts)
  } else { emptylist(opts) }
}

#' @noRd
names_ecoengine <- function(sources, query, limit, callopts, opts){
  if (any(grepl("gbif", sources))) {
    emptylist(opts)
  } else { emptylist(opts) }
}

#' @noRd
names_antweb <- function(sources, query, limit, callopts, opts){
  if (any(grepl("gbif", sources))) {
    emptylist(opts)
  } else { emptylist(opts) }
}

emptylist <- function(x) list(time = NULL, found = NULL, data = data.frame(NULL), opts = x)
