import termtools
import strutils
import std/exitprocs

initTermTools()
addExitProc proc() =
  deinitTermTools()


stdout.write "bold".bold & " "
stdout.write "faint".faint & " "
stdout.write "italic".italic & " "
stdout.write "underline".underline & " "
stdout.write "crossout".crossout & " "
echo ""
stdout.write "overline".overline & " "
stdout.write "reverse".reverse & " "
stdout.write "blink".blink & " "
stdout.write "bold/faint/underline".bold.faint.underline
echo ""
for x in ["red", "#f90", "yellow", "green", "lightgreen", "cyan", "blue", "magenta", "gray", "#ffffff"]:
  stdout.write x.fgColor(x) & " "
echo ""
for x in ["red", "#f90", "yellow", "green", "lightgreen", "cyan", "blue", "magenta", "gray", "#ffffff"]:
  stdout.write x.fgColor("black").bgColor(x) & " "
echo ""

for x in ["😊", "世界", "olé"]:
  echo "width of ", $x, "<-- ", $cellWidth(x)
  echo "         ", "-".repeat(cellWidth(x))
