import termtools
import std/exitprocs

initTermTools()
addExitProc proc() =
  deinitTermTools()

# True colors:
# COLORTERM=24bit TERM=screen
#
# ANSI256:
# COLORTERM=yes
#
# ANSI:
# TERM=color
#

let hex = "048af"
for r in hex:
  for g in hex:
    for b in hex:
      let c = "#" & r & g & b
      stdout.write(c.fgColor(c) & " ")
      stdout.write(c.bgColor(c) & " ")
    stdout.write("\l")
echo "Detected color profile: ", $getColorProfile()