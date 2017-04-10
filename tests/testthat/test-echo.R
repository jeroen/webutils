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
  formdata <- parse_http(req$body, req$content_type)

  # foo = "blabla"
  expect_equal(rawToChar(formdata$foo$value), "blabla")
  expect_null(formdata$foo$content_type)

  # bar = charToRaw("boeboe")
  expect_equal(formdata$bar$value, charToRaw("boeboe"))
  expect_null(formdata$foo$content_type)

  # iris = form_data(serialize(iris, NULL), "application/rda"),
  expect_equal(formdata$iris$value, serialize(iris, NULL), "application/rda")
  expect_equal(formdata$iris$content_type, "application/rda")

  # description = form_file(system.file("DESCRIPTION")),
  expect_equal(formdata$description$value, readBin(desc, raw(), 1e5))
  expect_equal(formdata$description$content_type, "application/octet-stream")
  expect_equal(formdata$description$filename, "DESCRIPTION")

  # logo = form_file(file.path(Sys.getenv("R_DOC_DIR"), "html/logo.jpg"), "image/jpeg")
  expect_equal(formdata$logo$value, readBin(logo, raw(), 1e5));
  expect_equal(formdata$logo$content_type, "image/jpeg")
  expect_equal(formdata$logo$filename, "logo.jpg")
})

test_that("Echo a big file", {
  # Create a random file (~30 MB)
  # Note: can test even bigger files but curl_echo() is a bit slow on Windows
  tmp <- tempfile()
  n <- runif(1, 3e6, 4e6)
  buf <- serialize(rnorm(n), NULL)
  writeBin(buf, tmp)
  on.exit(unlink(tmp))

  # Roundtrip via httpuv
  h <- curl::handle_setform(curl::new_handle(), myfile = curl::form_file(tmp))
  req <- curl::curl_echo(h)
  formdata <- parse_http(req$body, req$content_type)

  # Tests
  expect_length(formdata$myfile$value, file.info(tmp)$size)
  expect_identical(formdata$myfile$filename, basename(tmp))
  expect_identical(formdata$myfile$value, buf)
})
