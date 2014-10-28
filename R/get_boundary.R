#' Extract boundary from header
#'
#' Helper function to extract the boundary value from the content-type
#' http request header.
#'
#' @export
#' @param content_type the Content-Type request header
#' @examples content_type = "multipart/form-data; boundary=----WebKitFormBoundaryxEQWPBrp9Wym1xpB"
#' get_boundary(content_type)
get_boundary <- function(content_type){
  # Remove header name if present
  content_type <- sub("Content-Type: ?", "", content_type, ignore.case=TRUE);

  # Check for multipart
  if(!grepl("multipart/form-data; boundary=", content_type, fixed=TRUE))
    stop("Content type is not multipart/form-data: ", content_type)

  # Extract bounary
  sub("multipart/form-data; boundary=", "", content_type, fixed=TRUE)
}
