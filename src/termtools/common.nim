import strutils

const
  ESC* = "\x1b["
  RESET_SEQ* = ESC & "0m"

proc reset*(s: string): string {.inline.} =
  ## Make sure the end of a string resets the style
  if not s.endsWith(RESET_SEQ):
    return s & RESET_SEQ
  else:
    return s