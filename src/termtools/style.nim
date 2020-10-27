import ./common

const
  BoldSeq = "1"
  FaintSeq = "2"
  ItalicSeq = "3"
  UnderlineSeq = "4"
  BlinkSeq = "5"
  ReverseSeq = "7"
  CrossOutSeq = "9"
  OverlineSeq = "53"

template wrapStyle(s: string, exc: string): string =
  reset(ESC & exc & "m" & s)

proc bold*(s: string): string {.inline.} = wrapStyle(s, BoldSeq)
proc faint*(s: string): string {.inline.} = wrapStyle(s, FaintSeq)
proc italic*(s: string): string {.inline.} = wrapStyle(s, ItalicSeq)
proc underline*(s: string): string {.inline.} = wrapStyle(s, UnderlineSeq)
proc crossout*(s: string): string {.inline.} = wrapStyle(s, CrossOutSeq)
proc overline*(s: string): string {.inline.} = wrapStyle(s, OverlineSeq)
proc reverse*(s: string): string {.inline.} = wrapStyle(s, ReverseSeq)
proc blink*(s: string): string {.inline.} = wrapStyle(s, BlinkSeq)
