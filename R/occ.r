#' Search for species occurrence data across many data sources.
#'
#' Search on a single species name, or many. And search across a single
#' or many data sources.
#'
#' @export
#' @family queries
#' @template occtemp
#' @template occ_egs
occ <- function(query = NULL, from = "gbif", limit = 500, start = NULL,
  page = NULL, geometry = NULL, has_coords = NULL, ids = NULL, date = NULL,
  callopts=list(),
  gbifopts = list(), bisonopts = list(), inatopts = list(),
  ebirdopts = list(), vertnetopts = list(), idigbioopts = list(),
  obisopts = list(), alaopts = list(), throw_warnings = TRUE) {

  assert(query, "character")
  assert(limit, c("numeric", "integer"))
  assert(start, c("numeric", "integer"))
  assert(page, c("numeric", "integer"))
  assert(has_coords, "logical")
  assert(date, c('character', 'Date'))
  assert(throw_warnings, "logical")
  Sys.setenv(SPOCC_THROW_ERRORS = throw_warnings)

  # type: the type of query. by default "sci" for scientific name
  #   below 'type' can be reset to "geometry" if its a geometry
  #   based query
  type <- "sci"

  geometry <- occ_geom(geometry)
  sources <- match.arg(from, choices = c("gbif", "bison", "inat", "ebird",
    "vertnet", "idigbio", "obis", "ala"),
    several.ok = TRUE)

  # collect all data sources opts into named list to index to later
  ds <- list(gbif=gbifopts, bison=bisonopts, inat=inatopts,
    ebird=ebirdopts, vertnet=vertnetopts,
    idigbio=idigbioopts, obis=obisopts, ala=alaopts)

  if (is.null(ids) && !is.null(query)) {
    # If query not null (taxonomic names passed in)
    ## if geometry a list, do multiple queries for each geometry element
    if (is.list(geometry)) {
      tmp <- list()
      for (i in seq_along(query)) {
        tmpres <- lapply(geometry, function(b) {
          occ_loopfun(z = b, y = limit, s = start, p = page,
            x = query[[i]], hc = has_coords, d = date, w = callopts,
            sources = sources, ds = ds)
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
      tmp <- lapply(query, occ_loopfun, y = limit, s = start, p = page,
        z = geometry, hc = has_coords, d = date, w = callopts,
        sources = sources, ds = ds)
    }
  } else if (is.null(query) && is.null(geometry) && !is.null(ids)) {
    ids <- occ_unlistids(ids)
    # if ids is not null (taxon identifiers passed in)
    # ids can only be passed to gbif and bison for now
    # so don't pass anything on to inat or ebird
    tmp <- lapply(ids, occ_loopids, y = limit, s = start, p = page,
      z = geometry, hc = has_coords, d = date, w = callopts,
      sources = sources, ds = ds)
  } else if (is.null(query) && is.null(geometry) && is.null(ids)) {
    tmp <- list(occ_loopfun(x = query, y = limit, s = start, p = page,
      z = geometry, hc = has_coords, d = date, w = callopts,
      sources = sources, ds = ds))
  } else {
    type <- 'geometry'
    if (is.numeric(geometry) || is.character(geometry)) {
      tmp <- list(occ_loopfun(z = geometry, y = limit, s = start, p = page,
        x = query, hc = has_coords, d = date, w = callopts,
        sources = sources, ds = ds))
    } else if (is.list(geometry)) {
      tmp <- lapply(geometry, function(b) {
        occ_loopfun(z = b, y = limit, s = start, p = page,
          x = query, hc = has_coords, d = date, w = callopts,
          sources = sources, ds = ds)
      })
    }
  }

  gbif_sp <- occ_getsplist(tmp, "gbif", sources, type, ds$gbif, query, geometry,
    ids)
  bison_sp <- occ_getsplist(tmp, "bison", sources, type, ds$bison, query, geometry,
    ids)
  inat_sp <- occ_getsplist(tmp, "inat", sources, type, ds$inat, query, geometry,
    ids)
  ebird_sp <- occ_getsplist(tmp, "ebird", sources, type, ds$ebird, query, geometry,
    ids)
  vertnet_sp <- occ_getsplist(tmp, "vertnet", sources, type, ds$vertnet, query,
    geometry, ids)
  idigbio_sp <- occ_getsplist(tmp, "idigbio", sources, type, ds$idigbio, query,
    geometry, ids)
  obis_sp <- occ_getsplist(tmp, "obis", sources, type, ds$obis, query, geometry,
    ids)
  ala_sp <- occ_getsplist(tmp, "ala", sources, type, ds$ala,
    query, geometry, ids)
  p <- list(gbif = gbif_sp, bison = bison_sp, inat = inat_sp, ebird = ebird_sp,
            vertnet = vertnet_sp, idigbio = idigbio_sp, obis = obis_sp,
            ala = ala_sp)
  structure(p, class = "occdat", searched = from)
}
