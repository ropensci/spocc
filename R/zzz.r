#' Capitalize the first letter of a character string.
#'
#' @param s A character string
#' @param strict Should the algorithm be strict about capitalizing. 
#' Default: `FALSE`
#' @param onlyfirst Capitalize only first word, lowercase all others. 
#' Useful for taxonomic names.
#' @examples \dontrun{
#' spocc_capwords(c('using AIC for model selection'))
#' spocc_capwords(c('using AIC for model selection'), strict=TRUE)
#' }
#' @export
#' @keywords internal
spocc_capwords <- function(s, strict = FALSE, onlyfirst = FALSE) {
    cap <- function(s) paste(toupper(substring(s, 1, 1)), {
        s <- substring(s, 2)
        if (strict)
            tolower(s) else s
    }, sep = "", collapse = " ")
    if (!onlyfirst) {
        vapply(strsplit(s, split = " "), cap, "", 
               USE.NAMES = !is.null(names(s)))
    } else {
        vapply(s, function(x) paste(toupper(substring(x, 1, 1)), 
                                    tolower(substring(x,
            2)), sep = "", collapse = " "), "", USE.NAMES = F)
    }
}

sc <- function(l) Filter(Negate(is.null), l)

pluck <- function(x, name, type) {
  if (missing(type)) {
    lapply(x, "[[", name)
  } else {
    vapply(x, "[[", name, FUN.VALUE = type)
  }
}

strextract <- function(str, pattern) regmatches(str, regexpr(pattern, str))

strtrim <- function(str) gsub("^\\s+|\\s+$", "", str)

time_null <- function(x) {
  if (length(sc(x)) == 0) NULL else sc(x)[[1]]
}

found_null <- function(x) {
  if (length(sc(x)) == 0) NULL else sum(unlist(sc(x)), na.rm = TRUE)
}

pluck_fill <- function(a, b) {
  if (is.null(b)) {
    NULL
  } else {
    if (b %in% names(a)) {
      b
    } else {
      NULL
    }
  }
}

check_for_package <- function(x) {
  if (!requireNamespace(x, quietly = TRUE)) {
    stop("Please install ", x, call. = FALSE)
  } else {
    invisible(TRUE)
  }
}

check_integer <- function(x) {
  !grepl("[^[:digit:]]", format(x,  digits = 20, scientific = FALSE))
}

is_numeric <- function(x) {
  if (!is.null(x)) {
    tt <- tryCatch(as.numeric(x), error = function(e) e, 
                   warning = function(w) w)
    if (inherits(tt, 'warning') || inherits(tt, 'error') || 
        typeof(x) == "list") {
      FALSE
    } else {
      check_integer(x)
    }
  } else {
    TRUE
  }
}

is_logical <- function(x) {
  if (!is.null(x)) {
    inherits(x, 'logical')
  } else {
    TRUE
  }
}

spocc_wrap <- function(..., indent = 0, width = getOption("width")){
  x <- paste0(..., collapse = "")
  wrapped <- strwrap(x, indent = indent, exdent = indent + 5, width = width)
  paste0(wrapped, collapse = "\n")
}

rbindl <- function(x) {
  xx <- data.table::setDF(data.table::rbindlist(x, fill = TRUE, 
                                                use.names = TRUE))
  xx
}

assert <- function(x, y) {
  if (!is.null(x)) {
    if (!inherits(x, y)) {
      stop(deparse(substitute(x)), " must be of class ",
        paste0(y, collapse = ", "), call. = FALSE)
    }
  }
}
