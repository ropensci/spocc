#' Search for species occurrence data across many data sources.
#'
#' Search on a single species name, or many. And search across a single
#' or many data sources.
#'
#' @export
#' @importFrom rgbif occ_search occ_get name_lookup
#' @importFrom rebird ebirdregion ebirdgeo
#' @importFrom ecoengine ee_observations ee_search
#' @importFrom rbison bison_solr bison bison_tax
#' @importFrom AntWeb aw_data
#' @importFrom rvertnet vertsearch
#' @importFrom ridigbio idig_search_records idig_view_records
#' @importFrom lubridate now ymd_hms ymd_hm ydm_hm ymd
#' @template occtemp
#' @template occ_egs
occ <- function(query = NULL, from = "gbif", limit = 500, geometry = NULL, has_coords = NULL,
  ids = NULL, callopts=list(), gbifopts = list(), bisonopts = list(), inatopts = list(),
  ebirdopts = list(), ecoengineopts = list(), antwebopts = list(),
  vertnetopts = list(), idigbioopts = list()) {

  type <- "sci"

  if (!is.null(geometry)) {
    if (class(geometry) %in% c('SpatialPolygons', 'SpatialPolygonsDataFrame')) {
      geometry <- as.list(handle_sp(geometry))
    }
  }
  sources <- match.arg(from, choices = c("gbif", "bison", "inat", "ebird",
                                         "ecoengine", "antweb", "vertnet", "idigbio"),
                       several.ok = TRUE)
  if (!all(from %in% sources)) {
    stop(sprintf("Woops, the following are not supported or spelled incorrectly: %s",
                 from[!from %in% sources]))
  }

  loopfun <- function(x, y, z, hc, w) {
    # x = query; y = limit; z = geometry; hc = has_coords; w = callopts
    gbif_res <- foo_gbif(sources, x, y, z, hc, w, gbifopts)
    bison_res <- foo_bison(sources, x, y, z, w, bisonopts)
    inat_res <- foo_inat(sources, x, y, z, hc, w, inatopts)
    ebird_res <- foo_ebird(sources, x, y, w, ebirdopts)
    ecoengine_res <- foo_ecoengine(sources, x, y, z, hc, w, ecoengineopts)
    antweb_res <- foo_antweb(sources, x, y, z, hc, w, antwebopts)
    vertnet_res <- foo_vertnet(sources, x, y, hc, w, vertnetopts)
    idigbio_res <- foo_idigbio(sources, x, y, z, hc, w, idigbioopts)
    list(gbif = gbif_res, bison = bison_res, inat = inat_res, ebird = ebird_res,
         ecoengine = ecoengine_res, antweb = antweb_res, vertnet = vertnet_res,
         idigbio = idigbio_res)
  }

  loopids <- function(x, y, z, hc, w) {
    classes <- class(x)
    if (!all(classes %in% c("gbifid", "tsn")))
      stop("Currently, taxon identifiers have to be of class gbifid or tsn")
    if (class(x) == 'gbifid') {
      gbif_res <- foo_gbif(sources, x, y, z, hc, w, gbifopts)
      bison_res <- list(time = NULL, data = data.frame(NULL))
    } else if (class(x) == 'tsn') {
      bison_res <- foo_bison(sources, x, y, z, w, bisonopts)
      gbif_res <- list(time = NULL, data = data.frame(NULL))
    }
    list(gbif = gbif_res,
         bison = bison_res,
         inat = list(time = NULL, data = data.frame(NULL)),
         ebird = list(time = NULL, data = data.frame(NULL)),
         ecoengine = list(time = NULL, data = data.frame(NULL)),
         antweb = list(time = NULL, data = data.frame(NULL)),
         vertnet = list(time = NULL, data = data.frame(NULL)),
         idigbio = list(time = NULL, data = data.frame(NULL))
    )
  }

  # check that one of query or ids is non-NULL
  if (!any(!is.null(query), !is.null(ids), !is.null(geometry)))
    stop("One of query, ids, or geometry parameters must be non-NULL")

  if (is.null(ids) && !is.null(query)) {
    # If query not null (taxonomic names passed in)
    tmp <- lapply(query, loopfun, y = limit, z = geometry, hc = has_coords, w = callopts)
  } else if (is.null(query) && is.null(geometry)) {
    unlistids <- function(x) {
      if (length(x) == 1) {
        if (is.null(names(x))) {
          list(x)
        } else {
          if (!names(x) %in% c("gbif", "itis"))
            list(x)
          else
            list(x[[1]])
        }
      } else {
        gg <- as.list(unlist(x, use.names = FALSE))
        hh <- as.vector(rep(vapply(x, class, ""), vapply(x, length, numeric(1))))
        if (all(hh == "character"))
          hh <- rep(class(x), length(x))
        for (i in seq_along(gg)) {
          class(gg[[i]]) <- hh[[i]]
        }
        return( gg )
      }
    }
    ids <- unlistids(ids)
    # if ids is not null (taxon identifiers passed in)
    # ids can only be passed to gbif and bison for now
    # so don't pass anything on to ecoengine, inat, or ebird
    tmp <- lapply(ids, loopids, y = limit, z = geometry, hc = has_coords, w = callopts)
  } else {
    type <- 'geometry'
    if (is.numeric(geometry) || is.character(geometry)) {
      tmp <- list(loopfun(z = geometry, y = limit, x = query, hc = has_coords, w = callopts))
    } else if (is.list(geometry)) {
      tmp <- lapply(geometry, function(b) loopfun(z = b, y = limit, x = query, hc = has_coords, w = callopts))
    }
  }

  getsplist <- function(srce, opts) {
    tt <- lapply(tmp, function(x) x[[srce]]$data)
    if (!is.null(query) && is.null(geometry)) { # query
      names(tt) <- gsub("\\s", "_", query)
      optstmp <- tmp[[1]][[srce]]$opts
    } else if (is.null(query) && !is.null(geometry)) { # geometry
      tt <- tt
      optstmp <- tmp[[1]][[srce]]$opts
    } else if (!is.null(query) && !is.null(geometry)) { # query & geometry
      names(tt) <- gsub("\\s", "_", query)
      optstmp <- tmp[[1]][[srce]]$opts
    } else if (is.null(query) && is.null(geometry)) {
      names(tt) <- sapply(tmp, function(x) unclass(x[[srce]]$opts[[1]]))
      tt <- tt[!vapply(tt, nrow, 1) == 0]
      opts <- sc(lapply(tmp, function(x) x[[srce]]$opts))
      optstmp <- unlist(opts)
      simplist <- function(b){
        splitup <- unique(names(b))
        sapply(splitup, function(d){
          tmp <- b[names(b) %in% d]
          if (length(unique(unname(unlist(tmp)))) == 1) {
            as.list(tmp[1])
          } else {
            outout <- list(unname(unlist(tmp)))
            names(outout) <- names(tmp)[1]
            outout
          }
        }, USE.NAMES = FALSE)
      }
      optstmp <- simplist(optstmp)
    }

    if (any(grepl(srce, sources))) {
      ggg <- list(meta = list(source = srce, time = tmp[[1]][[srce]]$time,
          found = tmp[[1]][[srce]]$found, returned = nrow(tmp[[1]][[srce]]$data),
          type = type, opts = optstmp), data = tt)
      class(ggg) <- "occdatind"
      ggg
    } else {
      ggg <- list(meta = list(source = srce, time = NULL, found = NULL, returned = NULL,
          type = NULL, opts = NULL), data = tt)
      class(ggg) <- "occdatind"
      ggg
    }
  }
  gbif_sp <- getsplist("gbif", gbifopts)
  bison_sp <- getsplist("bison", bisonopts)
  inat_sp <- getsplist("inat", inatopts)
  ebird_sp <- getsplist("ebird", ebirdopts)
  ecoengine_sp <- getsplist("ecoengine", ecoengineopts)
  antweb_sp <- getsplist("antweb", antwebopts)
  vertnet_sp <- getsplist("vertnet", vertnetopts)
  idigbio_sp <- getsplist("idigbio", idigbioopts)
  p <- list(gbif = gbif_sp, bison = bison_sp, inat = inat_sp, ebird = ebird_sp,
            ecoengine = ecoengine_sp, antweb = antweb_sp, vertnet = vertnet_sp,
            idigbio = idigbio_sp)
  structure(p, class = "occdat", searched = from)
}
