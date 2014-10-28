#' Demo multipart parser with httpuv
#'
#' This function starts a web server using httpuv and hosts a simple form which
#' will be parsed by the multipart parser.
#
#' @export
demo_httpuv <- function(){
  rook_handler <- function(env){

    # See Rook spec
    content_type <- env[["CONTENT_TYPE"]]
    http_method <- env[["REQUEST_METHOD"]]
    request_body <- env[["rook.input"]]$read()
    path <- env[["PATH_INFO"]]

    # Show HTML page for GET requests.
    if(http_method == "GET"){
      message("Received HTTP GET request: ", path)
      testpage <- system.file("testpage.html", package="multipart");
      list (
        status = 200,
        body = paste(readLines(testpage), collapse="\n"),
        headers = c("content-type" = "text/html")
      )
    } else {
      # Parse the multipart/form-data
      message("Received HTTP POST request.")
      boundary <- get_boundary(content_type)
      postdata <- parse_multipart(request_body, boundary)

      # Print it to the R console (just for fun)
      str(postdata)

      # process this form
      username <- rawToChar(as.raw(postdata$username$value))
      email <- rawToChar(as.raw(postdata$email_address$value))
      food <- rawToChar(as.raw(postdata$food$value))
      picture <- file.path(getwd(), basename(postdata$picture$filename))
      writeBin(as.raw(postdata$picture$value), picture)

      # return summary to the client
      list(
        status = 200,
        body = paste0("User: ", username, "\nEmail: ", email, "\nPicture (copy): ", picture,"\nFood: ", food, "\n"),
        headers = c("content-type" = "text/plain")
      )
    }
  }

  # Start httpuv
  httpuv::startDaemonizedServer("0.0.0.0", 12345, list(call = rook_handler))
  url <- paste0("http://localhost:12345/")
  message("Opening ", url)
  browseURL(url)
}
