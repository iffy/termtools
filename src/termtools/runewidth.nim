## Ported from https://github.com/mattn/go-runewidth
## This module provides the ``cellWidth`` proc for determining
## the monospace, visual width of a string.

import os
import strutils
import unicode
import algorithm
import ./widthdata

when defined(windows):
  proc getConsoleOutputCP(): cint {.stdcall, dynlib: "kernel32", importc: "GetConsoleOutputCP".}
  proc isEastAsianWidth(): bool =
    case getConsoleOutputCP()
    of 932, 51932, 936, 949, 950:
      return true
    else:
      return false
else:
  type
    ParsedLocale = tuple
      lang: string
      locale: string
      charset: string
  proc parseLocaleString(x: string): ParsedLocale =
    var
      charset = ""
      locale = ""
      lang = ""
    var x = x
    if "." in x:
      let parts = x.split(".", 1)
      x = parts[0]
      charset = parts[1]
    if "_" in x:
      let parts = x.split("_", 1)
      x = parts[0]
      locale = parts[1]
    lang = x
    result = (lang, locale, charset)
  
  proc isEastAsianWidth(): bool =
    # This logic is borrowed from https://github.com/mattn/go-runewidth/blob/d7c96bb0d64b172fe14ceb464d4830c3f7eb66ae/runewidth_posix.go
    # but I don't trust it and I'm not sure how to test it.
    let locale = getEnv("LC_CTYPE", getEnv("LANG"))
    if locale == "POSIX" or locale == "C":
      return false
    elif locale.len > 1 and locale[0] == 'C' and (locale[1] == '.' or locale[1] == '-'):
      return false
    if locale.endsWith("@cjk_narrow"):
      return false
    let parsed = locale.toLower().parseLocaleString()
    let charset = if "@" in parsed.charset: parsed.charset.split("@", 1)[1] else: parsed.charset
    if charset in ["utf-8","utf8","jis","eucjp","euckr","euccn","sjis","cp932","cp51932","cp936","cp949","cp950","big5","gbk","gb2312"]:
      if charset[0] != 'u' or locale.startsWith("ja") or locale.startsWith("ko") or locale.startsWith("zh"):
        return true


let DEFAULT_EASTASIANWIDTH = isEastAsianWidth()

proc inRangeArray*(x: int, ranges: openArray[Slice[int]]): bool =
  ## Return true if `x` is in any of the `ranges`
  if x < ranges[0].a:
    return false
  elif x > ranges[^1].b:
    return false

  result = -1 != binarySearch(ranges, x,
    proc(x: Slice[int], y: int): int =
      if y in x:
        return 0
      elif y < x.a:
        return 1
      else:
        return -1
  )

proc cellWidth*(r: Rune, eastAsianWidth = DEFAULT_EASTASIANWIDTH): int {.inline.} =
  if r.int < 0:
    return 0
  elif r.int > 0x10FFFF:
    return 0
  elif inRangeArray(r.int, nonprint) or inRangeArray(r.int, combining) or inRangeArray(r.int, notassigned):
    return 0
  elif eastAsianWidth and (inRangeArray(r.int, private) or inRangeArray(r.int, ambiguous)):
    return 2
  elif inRangeArray(r.int, doublewidth):
    return 2
  else:
    return 1

proc cellWidth*(s: string, eastAsianWidth = DEFAULT_EASTASIANWIDTH): int =
  ## Given a string, return the number of monospace/terminal cells
  ## occupied by the string.  For instance "世界" occupies 4 cells
  ## even though it's only 2 runes.
  runnableExamples:
    doAssert cellWidth("世界") == 4
    doAssert cellWidth("a") == 1
    doAssert cellWidth("😊") == 2

  for c in s.runes:
    result.inc c.cellWidth(eastAsianWidth)
