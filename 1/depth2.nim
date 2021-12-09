import std/[sugar, sequtils, strutils, os, enumerate]
from math import sum

# Usage:
# nim r depths2.nim INPUT_FILE

let input_file = open(os.paramStr(1))

var previous_sum = high(int)
var deeper: int = 0
var window: seq[int]

# Accumulate numbers into the window. Use enumerate to know when to start dropping numbers - after line 2.
for i, depth in enumerate(toSeq(lines(input_file)).map(parseInt)):
  dump depth
  if i > 2:
    window.delete(0)
  window.add(depth)
  dump window
  if len(window) < 3:
    continue
  let total = sum(window)
  echo total
  if total > previous_sum:
    inc deeper
    echo "*"
  previous_sum = total

echo deeper
