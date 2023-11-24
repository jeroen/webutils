#' Demo multipart parser with httpuv
#'
#' Starts the httpuv web server and hosts a simple form including a file
#' upload to demo the multipart parser.
#
#' @export
#' @family demo
#' @param port which port number to run the http server
demo_httpuv <- function(port = 9359){
  rook_handler <- function(env){

    # See Rook spec
    content_type <- env[["CONTENT_TYPE"]]
    http_method <- env[["REQUEST_METHOD"]]
    body <- env[["rook.input"]]$read()
    path <- env[["PATH_INFO"]]

    # Show HTML page for GET requests.
    if(tolower(http_method) %in% c("post", "put")){
      # Parse the multipart/form-data
      message("Received HTTP POST request.")
      postdata <- parse_http(body, content_type)

      # Print it to the R console (just for fun)
      utils::str(postdata)

      # process this form
      username <- rawToChar(as.raw(postdata$username$value))
      email <- rawToChar(as.raw(postdata$email_address$value))
      food <- rawToChar(as.raw(postdata$food$value))
      picture <- file.path(getwd(), basename(postdata$picture$filename))
      writeBin(postdata$picture$value, picture)

      # return summary to the client
      list(
        status = 200,
        body = paste0("User: ", username, "\nEmail: ", email, "\nPicture (copy): ", picture,"\nFood: ", food, "\n"),
        headers = c("Content-Type" = "text/plain")
      )
    } else {
      message("Received HTTP GET request: ", path)
      testpage <- system.file("testpage.html", package="webutils");
      stopifnot(file.exists(testpage))
      list (
        status = 200,
        body = paste(readLines(testpage), collapse="\n"),
        headers = c("Content-Type" = "text/html")
      )
    }
  }

  # Start httpuv
  if(!length(port))
    port <- httpuv::randomPort()
  server_id <- httpuv::startServer("0.0.0.0", port, list(call = rook_handler))
  on.exit({
    message("stopping server")
    httpuv::stopServer(server_id)
  }, add = TRUE)
  url <- paste0("http://localhost:", port, "/")
  message("Opening ", url)
  utils::browseURL(url)
  repeat {
    httpuv::service()
  }
}
