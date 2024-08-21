#' Parse a multipart/form-data request
#'
#' Parse a multipart/form-data request, which is usually generated from a HTML form
#' submission. The parameters can include both text values as well as binary files.
#' They can be distinguished from the presence of a `filename` attribute.
#'
#' A multipart/form-data request consists of a single body which contains one or more
#' values plus meta-data, separated using a boundary string. This boundary string
#' is chosen by the client (e.g. the browser) and specified in the `Content-Type`
#' header of the HTTP request. There is no escaping; it is up to the client to choose
#' a boundary string that does not appear in one of the values.
#'
#' The parser is written in pure R, but still pretty fast because it uses the regex
#' engine.
#'
#' @export
#' @param body body of the HTTP request. Must be raw or character vector.
#' @param boundary boundary string as specified in the `Content-Type` request header.
#' @examples \dontrun{example form
#' demo_rhttpd()
#' }
parse_multipart <- function(body, boundary){
  # Some HTTP daemons give the body as a string instead of raw.
  if(is.character(body))
    body <- charToRaw(paste(body, collapse=""))

  if(is.character(boundary))
    boundary <- charToRaw(boundary)

  # Heavy lifting in C
  stopifnot(is.raw(body), is.raw(boundary))
  form_data <- split_by_boundary(body, boundary)

  # Output
  out <- lapply(form_data, function(val){
    headers <- parse_header(val[[1]])
    c(list(
      value = val[[2]]
    ), headers)
  })

  names(out) <- sapply(out, `[[`, 'name');
  out
}

parse_header <- function(buf){
  headers <- strsplit(rawToChar(buf), "\r\n", fixed = TRUE)[[1]]
  out <- split_names(headers, ": ")
  if(length(out$content_disposition)){
    pieces <- strsplit(out$content_disposition, "; ")[[1]]
    out$content_disposition <- pieces[1]
    out <- c(out, lapply(split_names(pieces[-1], "="), unquote))
  }
  out
}

#' @useDynLib webutils R_split_boundary
split_by_boundary <- function(body, boundary){
  .Call(R_split_boundary, body, boundary)
}

#' @useDynLib webutils R_split_string
split_by_string <- function(string, split = ":"){
  .Call(R_split_string, string, split)
}

#' @useDynLib webutils R_unquote
unquote <- function(string){
  .Call(R_unquote, string)
}

split_names <- function(x, split){
  matches <- lapply(x, split_by_string, split)
  names <- chartr("-", "_", tolower(sapply(matches, `[[`, 1)))
  values <- lapply(matches, `[[`, 2)
  structure(values, names = names);
}
