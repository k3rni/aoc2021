import std/[sugar, sequtils, strutils, os, tables, algorithm, sets, enumerate]

# Usage:
# nim r digits INPUT_FILE

type
  Patterns = seq[string]
  Digits = seq[string]
  InputRow = tuple[patterns: Patterns, digits: Digits]

let input_file = open(paramStr(1))
var input: seq[InputRow] = collect:
  for row in lines(input_file):
    let parts: seq[string] = row.split(" | ").mapIt(it.strip(leading = true, trailing = true))
    (patterns: parts[0].splitWhitespace(), digits: parts[1].splitWhitespace())

var total_value = 0

for item in input:
  let all_segments = toHashSet("abcdefg")
  var shapes: array[10, HashSet[char]]
  var e_segment: HashSet[char]

  for pattern in item.patterns:
    let segments = toHashSet(pattern)
    case len(pattern):
      of 2: # a 1-shape
        shapes[1] = segments
      of 3: # a 7-shape
        shapes[7] = segments
      of 4: # a 4-shape
        shapes[4] = segments
      of 7:
        shapes[8] = segments
      else:
        discard

  while any(shapes, (s) => len(s) == 0):
    for pattern in item.patterns:
      let segments = toHashSet(pattern)
      case len(pattern):
        of 6: # 0, 6, 9
          if shapes[4] <= segments: # Includes a 4-shape. This is a 9
            shapes[9] = segments
            e_segment = all_segments - segments # And now we know which is the E segment
          else:
            # Intersecting with the 1-shape returns a set of 2 elements if it's a 0-shape,
            # and 1 elements if it's a 6-shape.
            let overlaps_one = len(intersection(segments, shapes[1]))
            if overlaps_one == 2:
              shapes[0] = segments
            elif overlaps_one == 1:
              shapes[6] = segments
        of 5: # 2, 3, 5
          if shapes[1] <= segments: # Includes a 1-shape, which makes it a 3-shape
            shapes[3] = segments
          elif len(e_segment) > 0:
           # Either a 2 or 5. Differentiate by E segment
            if e_segment <= segments:
              shapes[2] = segments
            elif disjoint(segments, e_segment):
              shapes[5] = segments
        else:
          discard

  var display_value = 0
  for digits in item.digits:
    let display = toHashSet(digits)
    for i, segments in shapes:
      if display == segments:
        echo "Matched display " & $display & " to digit " & $i
        display_value = display_value * 10 + i
        break

  dump display_value
  total_value += display_value


dump total_value


#     0:      1:      2:      3:      4:
#    aaaa    ,,,,    aaaa    aaaa    ,,,,
#   b    c  .    c  .    c  .    c  b    c
#   b    c  .    c  .    c  .    c  b    c
#    ,,,,    ,,,,    dddd    dddd    dddd
#   e    f  .    f  e    .  .    f  .    f
#   e    f  .    f  e    .  .    f  .    f
#    gggg    ,,,,    gggg    gggg    ,,,,

#     5:      6:      7:      8:      9:
#    aaaa    aaaa    aaaa    aaaa    aaaa
#   b    .  b    .  .    c  b    c  b    c
#   b    .  b    .  .    c  b    c  b    c
#    dddd    dddd    ,,,,    dddd    dddd
#   .    f  e    f  .    f  e    f  .    f
#   .    f  e    f  .    f  e    f  .    f
#    gggg    gggg    ,,,,    gggg    gggg

# Notes on similarity:
# 1, 4, 7, 8
# 9
# 3
# 2, 5
# 6, 0
# all four of the 4-shape's B C D F are included in the 9-shape
# When we know what's a 9 shape, we know the mapping of the missing E segment
# The 3-shape is the only 5-segment shape that includes both C and F from the 1-shape
# The 2-shape is the only 5-segment shape that includes the E segment
# The remaining 5-segment is therefore a 5-shape
# The 6-shape includes a 5-shape fully. If we identified a 9-shape previously, this also gives us the 0-shape.
