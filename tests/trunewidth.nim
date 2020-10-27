import unittest
import termtools
import unicode
import strutils

proc assertLen(x: string, n: int) =
  let actual = cellWidth(x)
  if actual != n:
    echo "Expecting len of -->" & x & "<-- to be " & $n
    echo "                    " & "-".repeat(n)
    echo "  but it was reported as ", $actual
    echo "  str : ", $x
    echo "  repr: ", x.repr
    for r in x.runes:
      echo "  hex : ", r.int.toHex(), " ", $r, " width=", $r.cellWidth
  if actual != n:
    doAssert false

test "cellWidth":
  assertLen("世界", 4)
  assertLen("a", 1)
  assertLen("😊", 2)
  assertLen($0x2060.Rune, 0)
  assertLen($0x2062.Rune, 0)
  assertLen("a" & $0x2060.Rune, 1)
  assertLen($0x00300.Rune, 0)
  assertLen("a" & $0x00300.Rune, 1)
  assertLen("olé", 3)
