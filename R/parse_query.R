#' Parse query string
#'
#' Parse http parameters from a query string. This includes unescaping
#' of url-encoded values.
#'
#' For http GET requests, the query string is specified
#' in the URL after the question mark. For http POST or PUT requests, the query
#' string can be used in the request body when the `Content-Type` header
#' is set to `application/x-www-form-urlencoded`.
#'
#' @export
#' @param query a url-encoded query string
#' @examples q <- "foo=1%2B1%3D2&bar=yin%26yang"
#' parse_query(q)
parse_query <- function(query){
  if(is.raw(query))
    query <- rawToChar(query);
  stopifnot(is.character(query));

  #httpuv includes the question mark in query string
  query <- sub("^[?]", "", query)
  query <- chartr('+',' ', query)

  #split by & character
  argstr <- strsplit(query, "&", fixed = TRUE)[[1]]
  args <- lapply(argstr, function(x){
    curl::curl_unescape(strsplit(x, "=", fixed = TRUE)[[1]])
  })
  values <- lapply(args, `[`, 2)
  names(values) <- vapply(args, `[`, character(1), 1)
  return(values)
}
