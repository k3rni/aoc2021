import std/[sugar, sequtils, strutils, os, tables, math]

# Usage:
# nim r vents INPUT_FILE

type
  Point = tuple[x: int, y: int]
  VentLine = tuple[head: Point, tail: Point]

func point(xy: seq[int]): Point = (x: xy[0], y: xy[1])

iterator vents_from_file(input: File): VentLine =
  for line in input.lines():
    let row = line.split(" -> ", 1)
    let head = row[0].split(",", 1).map(parseInt)
    let tail = row[1].split(",", 1).map(parseInt)
    yield (head: point(head), tail: point(tail))

func is_horizontal(line: VentLine): bool = line.head.y == line.tail.y
func is_vertical(line: VentLine): bool = line.head.x == line.tail.x

iterator horizontal(line: VentLine): Point =
  let low = min(line.head.x, line.tail.x)
  let high = max(line.head.x, line.tail.x)
  for x in low..high:
    yield (x, line.head.y)

iterator vertical(line: VentLine): Point =
  let low = min(line.head.y, line.tail.y)
  let high = max(line.head.y, line.tail.y)
  for y in low..high:
    yield (line.head.x, y)

iterator diagonal(line: VentLine): Point =
  var (x, y) = (line.head.x, line.head.y)
  let xstep: int = sgn(line.tail.x - line.head.x) # Never zero - handled by vertical
  let ystep: int = sgn(line.tail.y - line.head.y) # Zero case handled by horizontal
  while true:
    yield (x, y)
    if x == line.tail.x and y == line.tail.y:
      break
    y += ystep
    x += xstep

func points_on_line(line: VentLine): seq[Point] =
  if is_horizontal(line):
    toSeq(horizontal(line))
  elif is_vertical(line):
    toSeq(vertical(line))
  else:
    toSeq(diagonal(line))

let vents = toSeq(vents_from_file(open(paramStr(1))))
# let used_vents = vents.filter((vent: VentLine) => is_horizontal(vent) or is_vertical(vent))

var counts = initCountTable[Point]()
for vent in vents:
  dump vent
  for point in points_on_line(vent):
    echo "inc(" & $point & ")"
    counts.inc(point)

dump counts

let dang = toSeq(counts.values).filterIt(it > 1).len()
dump dang
