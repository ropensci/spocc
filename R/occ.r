#' Search for species occurrence data across many data sources.
#'
#' Search on a single species name, or many. And search across a single
#' or many data sources.
#'
#' @export
#' @template occtemp
#' @template occ_egs
occ <- function(query = NULL, from = "gbif", limit = 500, start = NULL, 
  page = NULL, geometry = NULL, has_coords = NULL, ids = NULL, callopts=list(),
  gbifopts = list(), bisonopts = list(), inatopts = list(),
  ebirdopts = list(), ecoengineopts = list(), antwebopts = list(),
  vertnetopts = list(), idigbioopts = list(), obisopts = list(), 
  alaopts = list()) {

  type <- "sci"

  # if query not NULL, has to be character
  if (!is.null(query)) {
    if (!inherits(query, "character")) {
      stop("'query' param. must be of class character", call. = FALSE)
    }
  }

  # limit, start, and page must be an integer
  if (!is_numeric(limit)) stop("'limit' must be an integer", call. = FALSE)
  if (!is_numeric(start)) stop("'start' must be an integer", call. = FALSE)
  if (!is_numeric(page)) stop("'page' must be an integer", call. = FALSE)

  # has_coords must be a boolean
  if (!is_logical(has_coords)) stop("'has_coords' must be logical (TRUE/FALSE)", 
                                    call. = FALSE)

  if (!is.null(geometry)) {
    if (class(geometry) %in% c('SpatialPolygons', 'SpatialPolygonsDataFrame')) {
      geometry <- as.list(handle_sp(geometry))
    }
  }
  sources <- match.arg(from, choices = c("gbif", "bison", "inat", "ebird",
            "ecoengine", "antweb", "vertnet", "idigbio", "obis", "ala"),
                       several.ok = TRUE)
  if (!all(from %in% sources)) {
    stop(
      sprintf(
        "Woops, the following are not supported or spelled incorrectly: %s",
        from[!from %in% sources]))
  }

  loopfun <- function(x, y, s, p, z, hc, w) {
    # x = query; y = limit; s = start; p = page;
    # z = geometry; hc = has_coords; w = callopts
    gbif_res <- foo_gbif(sources, x, y, s, z, hc, w, gbifopts)
    bison_res <- foo_bison(sources, x, y, s, z, w, bisonopts)
    inat_res <- foo_inat(sources, x, y, p, z, hc, w, inatopts)
    ebird_res <- foo_ebird(sources, x, y, w, ebirdopts)
    ecoengine_res <- foo_ecoengine(sources, x, y, p, z, hc, w, ecoengineopts)
    antweb_res <- foo_antweb(sources, x, y, s, z, hc, w, antwebopts)
    vertnet_res <- foo_vertnet(sources, x, y, hc, w, vertnetopts)
    idigbio_res <- foo_idigbio(sources, x, y, s, z, hc, w, idigbioopts)
    obis_res <- foo_obis(sources, x, y, s, z, hc, w, obisopts)
    ala_res <- foo_ala(sources, x, y, s, z, hc, w, alaopts)
    list(gbif = gbif_res, bison = bison_res, inat = inat_res, ebird = ebird_res,
         ecoengine = ecoengine_res, antweb = antweb_res, vertnet = vertnet_res,
         idigbio = idigbio_res, obis = obis_res, ala = ala_res)
  }

  loopids <- function(x, y, s, p, z, hc, w) {
    classes <- class(x)
    if (!all(classes %in% c("gbifid", "tsn")))
      stop("Currently, taxon identifiers have to be of class gbifid or tsn",
           call. = FALSE)
    if (class(x) == 'gbifid') {
      gbif_res <- foo_gbif(sources, x, y, s, z, hc, w, gbifopts)
      bison_res <- list(time = NULL, data = data_frame())
    } else if (class(x) == 'tsn') {
      bison_res <- foo_bison(sources, x, y, s, z, w, bisonopts)
      gbif_res <- list(time = NULL, data = data_frame())
    }
    list(gbif = gbif_res,
         bison = bison_res,
         inat = list(time = NULL, data = data_frame()),
         ebird = list(time = NULL, data = data_frame()),
         ecoengine = list(time = NULL, data = data_frame()),
         antweb = list(time = NULL, data = data_frame()),
         vertnet = list(time = NULL, data = data_frame()),
         idigbio = list(time = NULL, data = data_frame()),
         obis = list(time = NULL, data = data_frame()),
         ala = list(time = NULL, data = data_frame())
    )
  }

  # check that one of query or ids is non-NULL
  # if (!any(!is.null(query), !is.null(ids), !is.null(geometry)))
  #   stop("One of query, ids, or geometry parameters must be non-NULL")

  if (is.null(ids) && !is.null(query)) {
    # If query not null (taxonomic names passed in)
    ## if geometry a list, do multiple queries for each geometry element
    if (is.list(geometry)) {
      tmp <- list()
      for (i in seq_along(query)) {
        tmpres <- lapply(geometry, function(b) {
          loopfun(z = b,
                  y = limit,
                  s = start,
                  p = page,
                  x = query[[i]],
                  hc = has_coords,
                  w = callopts)
        })

        collsinglefrom <- list()
        allfrom <- names(tmpres[[1]])
        for (j in seq_along(allfrom)) {
          srctmp <- lapply(tmpres, "[[", allfrom[j])
          collsinglefrom[[ allfrom[j] ]] <- list(
            time = time_null(pluck(srctmp, "time")),
            found = found_null(pluck(srctmp, "found")),
            data = rbind_fill(pluck(srctmp, "data")),
            opts = sc(list(
              hasCoordinate = srctmp[[1]]$opts$hasCoordinate,
              scientificName = unlist(
                unique(pluck(srctmp, c("opts", "scientificName")))),
              limit = srctmp[[1]]$opts$limit,
              fields = srctmp[[1]]$opts$fields,
              geometry = unlist(pluck(srctmp, c("opts", "geometry"))),
              config = srctmp[[1]]$opts$config
            ))
          )
        }

        tmp[[i]] <- collsinglefrom
      }
    } else {
      tmp <- lapply(query, loopfun, y = limit, s = start, p = page,
                    z = geometry, hc = has_coords, w = callopts)
    }
  } else if (is.null(query) && is.null(geometry) && !is.null(ids)) {
    unlistids <- function(x) {
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
        return( gg )
      }
    }
    ids <- unlistids(ids)
    # if ids is not null (taxon identifiers passed in)
    # ids can only be passed to gbif and bison for now
    # so don't pass anything on to ecoengine, inat, or ebird
    tmp <- lapply(ids, loopids, y = limit, s = start, p = page,
                  z = geometry, hc = has_coords, w = callopts)
  } else if (is.null(query) && is.null(geometry) && is.null(ids)) {
    tmp <- list(loopfun(x = query, y = limit, s = start, p = page,
                  z = geometry, hc = has_coords, w = callopts))
  } else {
    type <- 'geometry'
    if (is.numeric(geometry) || is.character(geometry)) {
      tmp <- list(loopfun(z = geometry, y = limit, s = start, p = page,
                          x = query, hc = has_coords, w = callopts))
    } else if (is.list(geometry)) {
      tmp <- lapply(geometry, function(b) {
        loopfun(z = b, y = limit, s = start, p = page,
                x = query, hc = has_coords, w = callopts)
      })
    }
  }
  
  getsplist <- function(srce, opts) {
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
    } else if (is.null(query) && is.null(geometry) && is.null(ids)) { 
      # nothing passed except opts
      names(tt) <- rep("custom_query", length(tt))
      optstmp <- tmp[[1]][[srce]]$opts
    }

    if (any(grepl(srce, sources))) {
      ggg <- list(meta = list(
        source = srce,
        time = time_null(pluck(tmp, c(srce, "time"))),
        found = sum(unlist(pluck(tmp, c(srce, "found")))),
        returned = sum(sapply(pluck(tmp, c(srce, "data")), NROW)),
        type = type,
        opts = optstmp),
        data = tt)
      structure(ggg, class = "occdatind")
    } else {
      ggg <- list(meta = list(source = srce, time = NULL, found = NULL, 
                              returned = NULL,
          type = NULL, opts = NULL), data = tt)
      structure(ggg, class = "occdatind")
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
  obis_sp <- getsplist("obis", obisopts)
  ala_sp <- getsplist("ala", alaopts)
  p <- list(gbif = gbif_sp, bison = bison_sp, inat = inat_sp, ebird = ebird_sp,
            ecoengine = ecoengine_sp, antweb = antweb_sp, vertnet = vertnet_sp,
            idigbio = idigbio_sp, obis = obis_sp, ala = ala_sp)
  structure(p, class = "occdat", searched = from)
}
