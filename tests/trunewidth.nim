import unittest
import termtools
import unicode
import strutils

proc assertLen(x: string, n: int): bool =
  let actual = cellWidth(x)
  echo "Expecting len of -->" & x & "<-- to be " & $n
  echo "                    " & "-".repeat(n)
  if actual != n:
    echo "  but it was reported as ", $actual
    echo "  str : ", $x
    echo "  repr: ", x.repr
    for r in x.runes:
      echo "  hex : ", r.int.toHex(), " ", $r, " width=", $r.runeWidth
  result = actual == n

test "cellWidth":
  check assertLen("世界", 4)
  check assertLen("a", 1)
  check assertLen("😊", 2)
  check assertLen($0x2060.Rune, 0)
  check assertLen($0x2062.Rune, 0)
  check assertLen("a" & $0x2060.Rune, 1)
  check assertLen($0x00300.Rune, 0)
  check assertLen("a" & $0x00300.Rune, 1)
  check assertLen("olé", 3)

  check assertLen("u̲", 1)
  check assertLen("ю́", 1)
  check assertLen("👨‍👩‍👧‍👦", 2)
  check assertLen("u̲n̲d̲e̲r̲l̲i̲n̲e̲d̲", 10)