import std/[sugar, strutils, os, bitops, algorithm, parseutils]

# Usage:
# nim r diag INPUT_FILE

let input_file = open(os.paramStr(1))

const WIDTH = 16
var ones: array[WIDTH, uint]
var zeros: array[WIDTH, uint]
var maxwidth: int = -1

for line in lines(input_file):
  var n: uint
  let len = parseBin(line, n, 0, WIDTH)
  maxwidth = max(maxwidth, len)
  if len > 0:
    for i in 0..<WIDTH:
      if testBit(n, i):
        ones[i] += 1
      else:
        zeros[i] += 1

dump maxwidth
dump @[ones, zeros]


var gamma: uint = 0
for i in countdown(maxwidth-1, 0):
  if ones[i] >= zeros[i]:
    gamma = 2 * gamma + 1
  else:
    gamma = 2 * gamma

var epsilon = bitnot(gamma)
# Bitnot returned a full 32-bit (or whatever-size) integer. We only want a part of that
bitSlice(epsilon, 0..<maxwidth)
dump [gamma, epsilon]

echo gamma * epsilon
