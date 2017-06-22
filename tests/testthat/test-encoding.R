context("encoding")

test_that("Encoding is retained", {
  strings <- c(
    "Zürich",
    "北京填鴨们",
    "ผัดไทย",
    "寿司",
    rawToChar(as.raw(1:40)),
    "?foo&bar=baz!bla\n"
  )
  encstr <- curl::curl_escape(strings)
  data <- paste(encstr, encstr, collapse = "&", sep = "=")
  out <- webutils::parse_query(data)
  expect_equal(names(out), strings)
  expect_equal(unlist(unname(out)), strings)
})
