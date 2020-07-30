empty_time_data <- function() {
  list(time = NULL, data = tibble())
}

occ_loopfun <- function(x, y, s, p, z, hc, d, w, sources, ds) {
  # x = query; y = limit; s = start; p = page;
  # z = geometry; hc = has_coords; d = date; w = callopts
  gbif_res <- foo_gbif(sources, x, y, s, z, hc, d, w, ds$gbif)
  bison_res <- foo_bison(sources, x, y, s, z, d, w, ds$bison)
  inat_res <- foo_inat(sources, x, y, p, z, hc, d, w, ds$inat)
  ebird_res <- foo_ebird(sources, x, y, w, ds$ebird)
  ecoengine_res <- foo_ecoengine(sources, x, y, p, z, hc, d, w, ds$ecoengine)
  vertnet_res <- foo_vertnet(sources, x, y, hc, d, w, ds$vertnet)
  idigbio_res <- foo_idigbio(sources, x, y, s, z, hc, d, w, ds$idigbio)
  obis_res <- foo_obis(sources, x, y, s, z, hc, d, w, ds$obis)
  ala_res <- foo_ala(sources, x, y, s, z, hc, d, w, ds$ala)
  list(gbif = gbif_res, bison = bison_res, inat = inat_res, ebird = ebird_res,
       ecoengine = ecoengine_res, vertnet = vertnet_res,
       idigbio = idigbio_res, obis = obis_res, ala = ala_res)
}

occ_loopids <- function(x, y, s, p, z, hc, d, w, sources, ds) {
  classes <- class(x)
  if (!all(classes %in% c("gbifid", "tsn")))
    stop("Currently, taxon identifiers have to be of class gbifid or tsn",
         call. = FALSE)
  if (inherits(x, 'gbifid')) {
    gbif_res <- foo_gbif(sources, x, y, s, z, hc, d, w, ds$gbif)
    bison_res <- empty_time_data()
  } else if (inherits(x, 'tsn')) {
    bison_res <- foo_bison(sources, x, y, s, z, d, w, ds$bison)
    gbif_res <- empty_time_data()
  }
  list(gbif = gbif_res,
       bison = bison_res,
       inat = empty_time_data(),
       ebird = empty_time_data(),
       ecoengine = empty_time_data(),
       vertnet = empty_time_data(),
       idigbio = empty_time_data(),
       obis = empty_time_data(),
       ala = empty_time_data()
  )
}

occ_getsplist <- function(tmp, srce, sources, type, opts, query, geometry, ids) {
  tt <- lapply(tmp, function(x) x[[srce]]$data)
  if (!is.null(query) && is.null(geometry)) { # query
    names(tt) <- gsub("\\s", "_", query)
    optstmp <- tmp[[1]][[srce]]$opts
  } else if (is.null(query) && !is.null(geometry)) {
    # geometry
    tt <- tt
    optstmp <- tmp[[1]][[srce]]$opts
  } else if (!is.null(query) && !is.null(geometry)) {
    # query & geometry
    names(tt) <- gsub("\\s", "_", query)
    optstmp <- tmp[[1]][[srce]]$opts
    optstmp$scientificName <- unique(names(tt))
  } else if (is.null(query) && is.null(geometry) && !is.null(ids)) {
    # neither query or geometry
    if (srce == "gbif") {
      names(tt) <- sapply(tmp, function(x) unname(unlist(x[[srce]]$opts$taxonKey)))
    } else {
      names(tt) <- sapply(tmp, function(x) unname(unlist(x[[srce]]$opts$TSNs)))
    }
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
  } else if (is.null(query) && is.null(geometry) && is.null(ids)) { 
    # nothing passed except opts
    names(tt) <- rep("custom_query", length(tt))
    optstmp <- tmp[[1]][[srce]]$opts
  }

  if (any(grepl(srce, sources))) {
    ggg <- list(
      meta = list(
        source = srce,
        time = time_null(pluck(tmp, c(srce, "time"))),
        found = sum(unlist(pluck(tmp, c(srce, "found")))),
        returned = sum(sapply(pluck(tmp, c(srce, "data")), NROW)),
        type = type,
        opts = optstmp,
        errors = unlist(pluck(tmp, c(srce, "errors")))
      ),
      data = tt
    )
    structure(ggg, class = "occdatind")
  } else {
    ggg <- list(
      meta = list(
        source = srce, time = NULL, found = NULL, returned = NULL,
        type = NULL, opts = NULL, errors = NULL
      ), 
      data = tt
    )
    structure(ggg, class = "occdatind")
  }
}

occ_unlistids <- function(x) {
  if (length(x) == 1) {
    if (is.null(names(x))) {
      list(x)
    } else {
      if (!names(x) %in% c("gbif", "itis")) {
        list(x)
      } else {
        list(x[[1]])
      }
    }
  } else {
    gg <- as.list(unlist(x, use.names = FALSE))
    hh <- as.vector(rep(vapply(x, class, ""), vapply(x, length, 
      numeric(1))))
    if (all(hh == "character"))
      hh <- rep(class(x), length(x))
    for (i in seq_along(gg)) {
      class(gg[[i]]) <- hh[[i]]
    }
    return(gg)
  }
}

strip_classes <- function(x, z) {
  class(x) <- class(x)[!class(x) %in% z]
  return(x)
}

occ_geom <- function(x) {
  if (!is.null(x)) {
    if (inherits(x, c('SpatialPolygons', 'SpatialPolygonsDataFrame'))) {
      x <- as.list(handle_sp(x))
    }
    if (inherits(x, c('sf', 'sfc', 'sfg', 'POLYGON', 'MULTIPOLYGON'))) {
      x <- strip_classes(x, c("XY", "data.frame", "sfc_POLYGON"))
      x <- as.list(handle_sf(x))
    }
  }
  return(x)
}
