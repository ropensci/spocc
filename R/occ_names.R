#' Search for species names across many data sources.
#'
#' @export
#' @family queries
#'
#' @param query (character) One to many names. Either a scientific name or a 
#' common name. Only scientific names supported right now.
#' @param from (character) Data source to get data from, any combination of 
#' gbif or bison
#' @param limit (numeric) Number of records to return. This is passed across 
#' all sources. To specify different limits for each source, use the options 
#' for each source (gbifopts, bisonopts). See Details for more.
#' @param rank (character) Taxonomic rank to limit search space. Used in GBIF, 
#' but not used in BISON.
#' @param callopts Options passed on to [crul::HttpClient()], e.g., for 
#' debugging curl calls, setting timeouts, etc.
#' @param gbifopts (list) List of named options to pass on to 
#' [rgbif::name_lookup()]. See also [spocc::occ_names_options()]
#' @param bisonopts (list) List of named options to pass on to 
#' [rbison::bison_tax()]. See also [spocc::occ_names_options()]
#'
#' @details Not all 7 data sources available from the [occ()] function are
#' available here, as not all of those sources have functionality to search 
#' for names.
#'
#' We strongly encourage you to use the `taxize` package if you want to 
#' search for taxonomic or common names, convert common to scientific names, 
#' etc. That package was built exactly for that purpose, and we only provide 
#' a bit of name searching here in this function.
#'
#' @examples \dontrun{
#' # Single data sources
#' ## gbif
#' (res <- occ_names(query = 'Accipiter striatus', from = 'gbif'))
#' head(res$gbif$data[[1]])
#'
#' ## bison
#' (res <- occ_names(query = '*bear', from = 'bison'))
#' res$bison$data
#' }

occ_names <- function(query = NULL, from = "gbif", limit = 100, 
  rank = "species", callopts=list(), gbifopts = list(), bisonopts = list()) {

  sources <- match.arg(from, choices = c("gbif", "bison"), 
                       several.ok = TRUE)
  tmp <- lapply(query, loopfun, y = limit, w = callopts, src = sources, 
                op = list(gbi = gbifopts, bis = bisonopts)
  )
  gbif_sp <- getnameslist(tmp, "gbif", sources, query, gbifopts)
  bison_sp <- getnameslist(tmp, "bison", sources, query, bisonopts)
  structure(list(gbif = gbif_sp, bison = bison_sp), class = "occnames")
}

loopfun <- function(x, y, w, op, src) {
  # x = query; y = limit; w = callopts; op=source options
  gbif_res <- names_gbif(src, x, y, w, op$gbi)
  bison_res <- names_bison(src, x, y, w, op$bis)
  list(gbif = gbif_res, bison = bison_res)
}

getnameslist <- function(tmp, srce, sources, q, opts) {
  tt <- lapply(tmp, function(x) x[[srce]]$data)
  names(tt) <- gsub("\\s", "_", q)
  optstmp <- tmp[[1]][[srce]]$opts

  if (any(grepl(srce, sources))) {
    structure(list(meta = list(source = srce, time = tmp[[1]][[srce]]$time,
        found = tmp[[1]][[srce]]$found, returned = nrow(tmp[[1]][[srce]]$data),
          opts = optstmp), data = tt), class = "occnamesind")
  } else {
    structure(list(meta = list(source = srce, time = NULL, found = NULL, returned = NULL,
          opts = NULL), data = tt), class = "occnamesind")
  }
}

#' @export
#' @rdname spocc_objects
#' @family queries
print.occnames <- function(x, ...) {
  rows <- lapply(x, function(y) vapply(y$data, nrow, numeric(1)))
  perspp <- lapply(rows, function(z) c(sum(z), length(z)))
  cat("Summary of results - occurrences found for:", "\n")
  cat(" gbif  :", perspp$gbif[1], "records across", perspp$gbif[2], "species",
      "\n")
  cat(" bison : ", perspp$bison[1], "records across", perspp$bison[2], "species",
      "\n")
}

#' @noRd
names_gbif <- function(sources, query, limit, callopts, opts){
  if (any(grepl("gbif", sources))) {
    if (is.null(query)) {
      emptylist(opts)
    } else {
      time <- now()
      opts$query <- query
      if (!'limit' %in% names(opts)) opts$limit <- limit
      opts$curlopts <- callopts
      out <- do.call(name_lookup, opts)
      if (is.character(out) || is.character(out$data)) {
        emptylist(opts)
      } else {
        dat <- out$data
        dat$prov <- rep("gbif", nrow(dat))
        list(time = time, found = out$meta$count, data = dat, opts = opts)
      }
    }
  } else {
    emptylist(opts)
  }
}

#' @noRd
names_bison <- function(sources, query, limit, callopts, opts){
  if (any(grepl("bison", sources))) {
    if (is.null(query)) {
      emptylist(opts)
    } else {
      time <- now()
      opts$query <- query
      if (!'limit' %in% names(opts)) opts$rows <- limit
      opts$callopts <- callopts
      out <- do.call(bison_tax, opts)
      if (is.character(out) || is.character(out$data)) {
        emptylist(opts)
      } else {
        dat <- out$names
        dat$prov <- rep("bison", nrow(dat))
        list(time = time, found = out$numFound, data = dat, opts = opts)
      }
    }
  } else {
    emptylist(opts)
  }
}
