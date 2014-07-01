#' Print brief summary of occ function output
#' 
#' @examples \dontrun{
#' spnames <- c('Accipiter striatus', 'Setophaga caerulescens', 'Spinus tristis')
#' out <- occ(query = spnames, from = 'gbif', gbifopts = list(hasCoordinate=TRUE))
#' print(out)
#' out # gives the same thing
#' 
#' # you can still drill down into the data easily
#' out$gbif$meta 
#' out$gbif$data
#' }
#' @method print occdat
#' @export
#' @rdname occdat
print.occdat <- function(x, ...) {
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

#' @method print occdatind
#' @export
#' @param x Input, of class occdatind
#' @param ... Further args, ignored
#' @rdname occdat
print.occdatind <- function(x, ..., n = 10){
#   namesprint <- paste(na.omit(names(x)[1:10]), collapse = " ")
  cat( spocc_wrap(sprintf("Species [%s]", pastemax(x$data))), '\n')
  cat(sprintf("First 10 rows of [%s]\n\n", names(x$data)[1] ))
  trunc_mat(x$data[[1]], n = n)
#   lengths <- vapply(x, nchar, 1, USE.NAMES = FALSE)
#   cat(sprintf("%s full-text articles retrieved", length(x)), "\n")
#   cat(sprintf("Min. Length: %s - Max. Length: %s", min(lengths), max(lengths)), "\n")
#   cat(spocc_wrap(sprintf("DOIs:\n %s ...", namesprint)), "\n\n")
#   cat("NOTE: extract xml strings like output['<doi>']")
}

pastemax <- function(z, n=10){
#   znames <- names(z)
#   znames <- gsub("_", " ", znames)
#   nn <- na.omit(znames[1:n])
  rrows <- vapply(z, nrow, integer(1))
  tt <- list(); for(i in seq_along(rrows)){ tt[[i]] <- sprintf("%s (%s)", gsub("_", " ", names(rrows[i])), rrows[[i]]) }
  paste0(tt, collapse = ", ")
}

#' Plot occ function output on a map (uses base plots via the rworldmap package)
#' 
#' @import sp rworldmap
#' @param x Input object from occ function, of class occdat
#' @param ... Further args passed on to points fxn
#' @examples \dontrun{
#' spnames <- c('Accipiter striatus', 'Setophaga caerulescens', 'Spinus tristis')
#' out <- occ(query=spnames, from='gbif', gbifopts=list(hasCoordinate=TRUE))
#' plot(out, cex=1, pch=10)
#' }
#' @method plot occdat
#' @export
#' @rdname occdat
plot.occdat <- function(x, ...) {
  df <- occ2df(x)
  coordinates(df) <- ~longitude + latitude
  proj4string(df) <- CRS("+init=epsg:4326")
  #     data(wrld_simpl, envir = new.env())
  #     data(wrld_simpl)
  #     world_simpl_obj <- wrld_simpl
  #     map(wrld_simpl)
  #     map("world")
  plot(getMap())
  points(df, col = "red", ...)
}

