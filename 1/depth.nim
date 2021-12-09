import std/[sequtils, strutils]

# Usage:
# nim r depths.nim INPUT_FILE

let input_file = open("depths.txt")

# For the first line, use high(int) which is like Int.max. No other int value compares as greater or equal.
var previous_depth: int = high(int)
var deeper: int = 0

for depth in toSeq(lines(input_file)).map(parseInt):
  echo depth
  if depth >= previous_depth:
    inc deeper
    echo "*"
  previous_depth = depth

echo deeper
