![Tests](https://github.com/iffy/termtools/workflows/tests/badge.svg?branch=master)

This is a Nim port of the excellent [termenv Go library](https://github.com/muesli/termenv).

See [examples/everything.nim](example/everything.nim) for an example of everything this library can do.

## Query Terminal Status

- [x] `getColorProfile()`
- [ ] `defaultForegroundColor()`
- [ ] `defaultBackgroundColor()`
- [ ] `hasDarkBackground()`

## Colors

`termtools` supports multiple color profiles: ANSI (16 colors), ANSI Extended
(256 colors), and TrueColor (24-bit RGB). Colors will automatically be degraded
to the best matching available color in the desired profile:

`TrueColor` => `ANSI 256 Colors` => `ANSI 16 Colors` => `Ascii`

```nim
import termtools

echo "red".fgColor("#f00")
echo "yellow background".bgColor("#ff0")
```

## Styles

```nim
import termtools

echo "bold".bold
echo "faint".faint
echo "italic".italic
echo "crossout".crossout
echo "underline".underline
echo "overline".overline
echo "reverse".reverse
echo "blink".blink
echo "combo".bold.faint.blink
```

## Strings

```nim
import termtools

doAssert "hello".cellWidth == 5
doAssert "😊".cellWidth == 2
```

## Screen

TODO: 
