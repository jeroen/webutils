get_boundary <- function(content_type){
  # Check for multipart
  if(!grepl("multipart/form-data;", content_type, fixed = TRUE) || !grepl("boundary=", content_type, fixed = TRUE))
    stop("Content type is not multipart/form-data: ", content_type)

  # Extract bounary
  m <- regexpr('boundary=[^; ]{2,}', content_type, ignore.case = TRUE)
  sub('boundary=','',regmatches(content_type, m)[[1]])
}
