#define _GNU_SOURCE
#include <Rinternals.h>
#include <string.h>
#include <stdint.h>

#if defined(_WIN32) || defined(__sun)
void * my_memmem(const void *l, size_t l_len, const void *s, size_t s_len);
#else
#define my_memmem memmem
#endif

//split by first CRLF
SEXP split_header(unsigned char * haystack, size_t n){
  SEXP out = PROTECT(allocVector(VECSXP, 2));
  unsigned char * cur = my_memmem(haystack, n, "\r\n\r\n", 4);
  if(cur){
    size_t len = cur - haystack;
    SEXP header = allocVector(RAWSXP, len);
    memcpy(RAW(header), haystack, len);
    SET_VECTOR_ELT(out, 0, header);
    SEXP body = allocVector(RAWSXP, n - len - 4);
    memcpy(RAW(body), cur + 4, n - len - 4);
    SET_VECTOR_ELT(out, 1, body);
    haystack = cur + 4;
    n -= len + 4;
  }
  SEXP body = allocVector(RAWSXP, n);
  memcpy(RAW(body), haystack, n);
  SET_VECTOR_ELT(out, 1, body);
  UNPROTECT(1);
  return out;
}

//split by arbitrary string
SEXP R_split_boundary(SEXP body, SEXP boundary){
  unsigned char * haystack = RAW(body);
  unsigned char * needle = RAW(boundary);

  //expect no more than 1000 boundaries
  unsigned char * offsets[1000] = { 0 };

  //initial values
  size_t n = Rf_length(body);
  size_t m = Rf_length(boundary);

  //find the needles
  int count = 0;
  unsigned char * cur = NULL;
  for(count = 0; (cur = my_memmem(haystack, n, needle, m)) && (n > m); count++){
    offsets[count] = cur;
    n = n - (cur - haystack) - m;
    haystack = cur + m;
  }

  //extract the
  if(count < 2)
    return allocVector(VECSXP, 0);

  //extract the payloads
  SEXP out = PROTECT(allocVector(VECSXP, count - 1));
  for(int i = 0; i < count - 1; i++){
    unsigned char * start = offsets[i] + m + 2; //drop ending CRLF
    unsigned char * end = offsets[i+1] - 4; //drop beginning CRLF + boundary preamble "--"
    size_t len = end - start;
    SET_VECTOR_ELT(out, i, split_header(start, len));
  }

  UNPROTECT(1);
  return out;
}

SEXP R_split_string(SEXP string, SEXP split){
  const char * str = CHAR(STRING_ELT(string, 0));
  const char * cut = CHAR(STRING_ELT(split, 0));
  char * out = strstr(str, cut);
  if(!out)
    return string;
  SEXP res = PROTECT(allocVector(STRSXP, 2));
  SET_STRING_ELT(res, 0, mkCharLen(str, out - str));
  SET_STRING_ELT(res, 1, mkChar(out + strlen(cut)));
  UNPROTECT(1);
  return res;
}

SEXP R_unquote(SEXP string){
  const char * str = CHAR(STRING_ELT(string, 0));
  size_t len = strlen(str);
  if(len > 1 && str[0] == '"' && str[len-1] == '"')
    return ScalarString(mkCharLen(str + 1, len - 2));
  return string;
}


#ifdef _WIN32
void * my_memmem(const void *l, size_t l_len, const void *s, size_t s_len)  {
  register char *cur, *last;
  const char *cl = (const char *)l;
  const char *cs = (const char *)s;

  /* we need something to compare */
  if (l_len == 0 || s_len == 0)
    return NULL;

  /* "s" must be smaller or equal to "l" */
  if (l_len < s_len)
    return NULL;

  /* special case where s_len == 1 */
  if (s_len == 1)
    return memchr(l, (int)*cs, l_len);

  /* the last position where its possible to find "s" in "l" */
  last = (char *)cl + l_len - s_len;

  for (cur = (char *)cl; cur <= last; cur++)
    if (cur[0] == cs[0] && memcmp(cur, cs, s_len) == 0)
      return cur;

    return NULL;
}
#endif
