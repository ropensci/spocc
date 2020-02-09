#' Coerce occurrence keys to vertnetkey/occkey objects
#'
#' @export
#' 
#' @family coercion
#'
#' @param x Various inputs, including the output from a call to [occ()]
#' (class occdat), [occ2df()] (class data.frame), or a list, numeric,
#' character, vertnetkey, or occkey.
#' @return One or more in a list of both class vertnetkey and occkey
#' @details Internally, we use [rvertnet::vert_id()], whereas [occ()]
#' uses [rvertnet::vertsearch()].
#' @examples \dontrun{
#' # spnames <- c('Accipiter striatus', 'Setophaga caerulescens',
#' #   'Spinus tristis')
#' # out <- occ(query=spnames, from='vertnet', has_coords=TRUE, limit=2)
#' # res <- occ2df(out)
#' # (tt <- as.vertnet(out))
#' # (uu <- as.vertnet(res))
#' # keys <- Filter(Negate(is.na), res$key)
#' # as.vertnet(keys[1])
#' # as.vertnet(as.list(keys[1:2]))
#' # as.vertnet(tt[[1]])
#' # as.vertnet(uu[[1]])
#' # as.vertnet(tt[1:2])
#' }
as.vertnet <- function(x) UseMethod("as.vertnet")

#' @export
as.vertnet.vertnetkey <- function(x) x

#' @export
as.vertnet.occkey <- function(x) x

#' @export
as.vertnet.occdat <- function(x) {
  x <- occ2df(x)
  make_vertnet_df(x)
}

#' @export
as.vertnet.data.frame <- function(x) make_vertnet_df(x)

#' @export
as.vertnet.character <- function(x) make_vertnet(as.numeric(x))

#' @export
as.vertnet.list <- function(x){
  lapply(x, function(z) {
    if (inherits(z, "vertnetkey")) {
      as.vertnet(z)
    } else {
      make_vertnet(as.numeric(z))
    }
  })
}

make_vertnet_df <- function(x){
  tmp <- x[ x$prov %in% "vertnet" ,  ]
  if (NROW(tmp) == 0) {
    stop("no data from vertnet found", call. = FALSE)
  } else {
    keys <- Filter(Negate(is.na), tmp$key)
    stats::setNames(lapply(keys, make_vertnet), keys)
  }
}

make_vertnet <- function(y){
  structure(rvertnet::vert_id(y), class = c("vertnetkey", "occkey"))
}
