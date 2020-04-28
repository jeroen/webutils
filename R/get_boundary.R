get_boundary <- function(content_type){
  # Check for multipart header
  if(!grepl("multipart/form-data;", content_type, fixed = TRUE))
    stop("Content type is not multipart/form-data: ", content_type)
  if(!grepl("boundary=", content_type, fixed = TRUE))
    stop("Multipart content-type header without boundary: ", content_type)

  # Extract bounary
  m <- regexpr('boundary=[^; ]{2,}', content_type, ignore.case = TRUE)
  sub('boundary=','',regmatches(content_type, m)[[1]])
}
