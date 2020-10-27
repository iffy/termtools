## Color-styling functions for strings
import terminal
import os
import math
import strutils
import strformat
import std/colors

import ./ansi_colors
import ./common

type
  ColorProfile* = enum
    Ascii,
    Ansi,
    Ansi256,
    TrueColor,
  
  TermColor* = object
    case profile: ColorProfile
    of Ascii:
      discard
    of Ansi:
      ansiColor: 0..16
    of Ansi256:
      ansi256: 16..255
    of TrueColor:
      native: Color

  AnsiColor* = enum
    AnsiBlack = 0
    AnsiRed
    AnsiGreen
    AnsiYellow
    AnsiBlue
    AnsiMagenta
    AnsiCyan
    AnsiWhite
    AnsiBrightBlack
    AnsiBrightRed
    AnsiBrightGreen
    AnsiBrightYellow
    AnsiBrightBlue
    AnsiBrightMagenta
    AnsiBrightCyan
    AnsiBrightWhite

const
  SEQ_FGCOLOR = "38"
  SEQ_BGCOLOR = "48"

when defined(windows):
  import winlean
  proc getConsoleMode(hConsoleHandle: Handle, dwMode: ptr DWORD): WINBOOL {.stdcall, dynlib: "kernel32", importc: "GetConsoleMode".}
  proc setConsoleMode(hConsoleHandle: Handle, dwMode: DWORD): WINBOOL {.stdcall, dynlib: "kernel32", importc: "SetConsoleMode".}
  
  const
    ENABLE_PROCESSED_OUTPUT = 0x0001
    ENABLE_WRAP_AT_EOL_OUTPUT = 0x0002
    ENABLE_VIRTUAL_TERMINAL_PROCESSING = 0x0004
    DISABLE_NEWLINE_AUTO_RETURN = 0x0008
    ENABLE_LVB_GRID_WORLDWIDE = 0x0010

  var gOldConsoleMode: DWORD

  proc initTermTools*() =
    if getConsoleMode(getStdHandle(STD_OUTPUT_HANDLE), gOldConsoleMode.addr) != 0:
      let mode = (gOldConsoleMode and (not ENABLE_WRAP_AT_EOL_OUTPUT)) or ENABLE_VIRTUAL_TERMINAL_PROCESSING
      discard setConsoleMode(getStdHandle(STD_OUTPUT_HANDLE), mode)
  
  proc deinitTermTools*() =
    discard setConsoleMode(getStdHandle(STD_OUTPUT_HANDLE), gOldConsoleMode)

else:
  proc initTermTools*() = discard
  proc deinitTermTools*() = discard

proc getColorProfile*(): ColorProfile =
  ## Return the current terminal's color profile
  if not stdout.isatty:
    return Ascii
  when defined(windows):
    return TrueColor
  else:
    if isTrueColorSupported():
      return TrueColor
    else:
      let
        term = getEnv("TERM").toLower()
        colorTerm = getEnv("COLORTERM").toLower()
      case colorTerm
      of "24bit", "truecolor":
        if term == "screen" or term.startsWith("screen"):
          return TrueColor
      of "yes", "true":
        return Ansi256
      else:
        if "256color" in term:
          return Ansi256
        elif "color" in term:
          return Ansi
    return Ascii

proc closest*(color: Color, options: openArray[Color]): Natural =
  ## Return the closest color within the given options
  ## TODO: Make this less naive
  var best = high(float)
  var best_i = 0
  let rgb = color.extractRGB()
  for i,option in options:
    let orgb = option.extractRGB()
    let diff = sqrt(((rgb.r - orgb.r)^2 + (rgb.g - orgb.g)^2 + (rgb.b - orgb.b)^2).toFloat)
    if diff < best:
      best = diff
      best_i = i
  return best_i

proc degrade*(color: TermColor, profile: ColorProfile): TermColor =
  ## Degrade a color to less capable profile, attempting to match the color somewhat.
  if color.profile == profile:
    return color
  case profile
  of Ascii:
    return TermColor(profile: Ascii)
  of Ansi:
    if color.profile == TrueColor:
      # TrueColor -> Ansi
      let best = color.native.closest(ANSI_HEX_COLORS[0..16])
      return TermColor(profile: Ansi, ansiColor: best)
    elif color.profile == Ansi256:
      # Ansi256 -> Ansi
      let ansiColor = ANSI_HEX_COLORS[color.ansi256 + 16]
      let best = ansiColor.closest(ANSI_HEX_COLORS[0..16])
      return TermColor(profile: Ansi, ansiColor: best)
    else:
      return color
  of Ansi256:
    if color.profile == TrueColor:
      # TrueColor -> Ansi256
      let best = color.native.closest(ANSI_HEX_COLORS[16..255]) + 16
      return TermColor(profile: Ansi256, ansi256: best)
    else:
      return color
  of TrueColor:
    # Already degraded
    return color

proc sequence*(color: TermColor, bg: bool): string =
  ## Return the terminal escape sequence for this color.
  ## `bg` = true for the background color sequence
  case color.profile
  of TrueColor:
    let rgb = color.native.extractRGB()
    if bg:
      result = ESC & SEQ_BGCOLOR & ";"
    else:
      result = ESC & SEQ_FGCOLOR & ";"
    result.add &"2;{rgb.r};{rgb.g};{rgb.b}m"
  of Ansi256:
    if bg:
      result = ESC & SEQ_BGCOLOR & ";"
    else:
      result = ESC & SEQ_FGCOLOR & ";"
    result.add &"5;" & $color.ansi256 & "m"
  of Ansi:
    let num = color.ansiColor.int
    if bg:
      result = ESC & SEQ_BGCOLOR & ";"
      if num < 8:
        result.add $(num + 10 + 30)
      else:
        result.add $(num + 10 - 8 + 90)
    else:
      result = ESC & SEQ_FGCOLOR & ";"
      if num < 8:
        result.add $(num + 30)
      else:
        result.add $(num - 8 + 90)
    result.add "m"
  else:
    discard

proc parseColor(color: string): Color =
  ## Convert #rgb or #rrggbb to RGBColor
  if color.startsWith("#") and color.len == 4:
    # '#rgb' format
    result = colors.parseColor("#" & color[1].repeat(2) & color[2].repeat(2) & color[3].repeat(2))
  else:
    result = colors.parseColor(color)

proc bestcolor(color: string): TermColor =
  ## Return the best color this terminal can support
  TermColor(profile: TrueColor, native: color.parseColor()).degrade(getColorProfile())

proc fgColor*(s: string, color: TermColor): string =
  ## Wrap the string with the given foreground color
  reset(color.sequence(bg=false) & s)

proc fgColor*(s: string, color: string): string {.inline.} =
  s.fgColor(bestcolor(color))

proc bgColor*(s: string, color: TermColor): string =
  ## Wrap the string with the given background color
  reset(color.sequence(bg=true) & s)

proc bgColor*(s: string, color: string): string {.inline.} =
  s.bgColor(bestcolor(color))
