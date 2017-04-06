context("echo with httpuv")

# Example with various types from 'curl' vignette
test_that("test echo from httpuv", {
  desc <- system.file("DESCRIPTION")
  logo <- file.path(Sys.getenv("R_DOC_DIR"), "html/logo.jpg")
  h <- curl::handle_setform(curl::new_handle(),
     foo = "blabla",
     bar = charToRaw("boeboe"),
     iris = curl::form_data(serialize(iris, NULL), "application/rda"),
     description = curl::form_file(desc),
     logo = curl::form_file(logo, "image/jpeg")
  )
  req <- curl::curl_echo(h)
  headers <- curl::parse_headers(req$headers)
  ctype <- grep("Content-Type:", headers, value = TRUE)
  boundary <- webutils:::get_boundary(ctype)
  out <- parse_multipart(req$content, boundary)

  # foo = "blabla"
  expect_equal(rawToChar(out$foo$value), "blabla")
  expect_null(out$foo$content_type)

  # bar = charToRaw("boeboe")
  expect_equal(out$bar$value, charToRaw("boeboe"))
  expect_null(out$foo$content_type)

  # iris = form_data(serialize(iris, NULL), "application/rda"),
  expect_equal(out$iris$value, serialize(iris, NULL), "application/rda")
  expect_equal(out$iris$content_type, "application/rda")

  # description = form_file(system.file("DESCRIPTION")),
  expect_equal(out$description$value, readBin(desc, raw(), 1e5))
  expect_equal(out$description$content_type, "application/octet-stream")
  expect_equal(out$description$filename, "DESCRIPTION")

  # logo = form_file(file.path(Sys.getenv("R_DOC_DIR"), "html/logo.jpg"), "image/jpeg")
  expect_equal(out$logo$value, readBin(logo, raw(), 1e5));
  expect_equal(out$logo$content_type, "image/jpeg")
  expect_equal(out$logo$filename, "logo.jpg")
})
