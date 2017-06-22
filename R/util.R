# Override default for call. argument
stop <- function(..., call. = FALSE){
  base::stop(..., call. = FALSE)
}

# Strip trailing whitespace
trail <- function(str){
  str <- sub("\\s+$", "", str, perl = TRUE);
  sub("^\\s+", "", str, perl = TRUE);
}

rawToChar <- function(x){
  out <- base::rawToChar(x)
  Encoding(out) <- 'UTF-8'
  out
}
