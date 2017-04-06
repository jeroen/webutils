context("fixed post data")

# Example with various types from 'curl' vignette
test_that("parsing example post", {
  buf <- readBin("posttypes", raw(), 1e6)
  out <- parse_multipart(buf, "------------------------ef343c1f05a612c3")

  # foo = "blabla"
  expect_equal(rawToChar(out$foo$value), "blabla")
  expect_null(out$foo$content_type)

  # bar = charToRaw("boeboe")
  expect_equal(out$bar$value, charToRaw("boeboe"))
  expect_null(out$foo$content_type)

  # iris = form_data(serialize(iris, NULL), "application/rda"),
  expect_equal(out$iris$value, readBin('iris.orig', raw(), 1e5))
  expect_equal(out$iris$content_type, "application/rda")

  # description = form_file(system.file("DESCRIPTION")),
  expect_equal(out$description$value, readBin('description.orig', raw(), 1e5));
  expect_equal(out$description$content_type, "application/octet-stream")
  expect_equal(out$description$filename, "DESCRIPTION")

  # logo = form_file(file.path(Sys.getenv("R_DOC_DIR"), "html/logo.jpg"), "image/jpeg")
  expect_equal(out$logo$value, readBin('logo.orig', raw(), 1e5));
  expect_equal(out$logo$content_type, "image/jpeg")
  expect_equal(out$logo$filename, "logo.jpg")
})
