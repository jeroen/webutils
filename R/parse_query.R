#' Parse query string
#'
#' Parse a query string (the part after the question mark of a URL). This
#' includes decoding of URL encoded values.
#'
#' @export
#' @importFrom utils URLdecode
#' @examples myquery <- "foo=1%2B1%3D2&bar=yin%26yang"
#' parse_query(myquery)
parse_query <- function(query){
  if(is.raw(query)){
    query <- rawToChar(query);
  }
  stopifnot(is.character(query));

  #httpuv includes the question mark in query string
  query <- sub("^[?]", "", query)

  #split by & character
  argslist <- sub("^&", "", regmatches(query, gregexpr("(^|&)[^=]+=[^&]+", query))[[1]])
  argslist <- strsplit(argslist, "=");
  ARGS <- lapply(argslist, function(x){if(length(x) < 2) "" else paste(x[-1], collapse="=")});
  ARGS <- lapply(ARGS, function(s) {URLdecode(chartr('+',' ',s))});
  names(ARGS) <- lapply(argslist, "[[", 1);
  return(ARGS)
}
