# webutils

##### *Utility Functions for Web Applications*

[![Build Status](https://travis-ci.org/jeroenooms/webutils.svg?branch=master)](https://travis-ci.org/jeroenooms/webutils)
[![AppVeyor Build Status](https://ci.appveyor.com/api/projects/status/github/jeroenooms/webutils?branch=master&svg=true)](https://ci.appveyor.com/project/jeroenooms/webutils)
[![Coverage Status](https://codecov.io/github/jeroenooms/webutils/coverage.svg?branch=master)](https://codecov.io/github/jeroenooms/webutils?branch=master)
[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/webutils)](http://cran.r-project.org/package=webutils)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/webutils)](http://cran.r-project.org/web/packages/webutils/index.html)
[![Github Stars](https://img.shields.io/github/stars/jeroenooms/webutils.svg?style=social&label=Github)](https://github.com/jeroenooms/webutils)

> Utility functions for developing web applications. Includes parsers
  for application/x-www-form-urlencoded as well as multipart/form-data
  and examples of using the parser with either httpuv or rhttpd.

## Hello World

```r
# Parse json encoded payload:
parse_http('{"foo":123, "bar":true}', 'application/json')

# Parse url-encoded payload
parse_http("foo=1%2B1%3D2&bar=yin%26yang", "application/x-www-form-urlencoded")

## Use demo app to parse multipart/form-data payload
demo_rhttpd()
```
