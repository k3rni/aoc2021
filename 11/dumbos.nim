import std/[sugar, strutils, os, sequtils, sets, enumerate]
import std/[terminal, colors]

type
  LevelsGrid = seq[seq[int]]
  Point = tuple[row: int, col: int]

let input_file = open(paramStr(1))
var levels: LevelsGrid = collect(for line in lines(input_file): collect(for ch in line.items: ord(ch) - ord('0')))
let num_turns = parseInt(paramStr(2))

func neighbors(levels: LevelsGrid, origin: Point): seq[Point] =
  let rows = 0..<len(levels)
  let cols = 0..<len(levels[0])
  var (r, c) = origin
  let all_eight: seq[Point] = @[(r - 1, c - 1), (r - 1, c), (r - 1, c + 1),
                                (r, c - 1),                 (r, c + 1),
                                (r + 1, c - 1), (r + 1, c), (r + 1, c + 1)]
  return all_eight.filterIt(rows.contains(it.row) and cols.contains(it.col))

proc show(levels: LevelsGrid) =
  for row in levels:
    for v in row:
      if v < 9:
        stdout.styledWrite(fgDefault, $chr(v + ord('0')), resetStyle)
      elif v == 9:
        stdout.styledWrite(styleBright, fgRed, $chr(v + ord('0')), resetStyle)
      else:
        stdout.styledWrite(styleBright, ansiForegroundColorCode(colWhite), "@", resetStyle)
    stdout.write "\n"
  stdout.write "\n"

## Increment everywhere
proc increment(levels: var LevelsGrid) =
  # Can't do a nested applyIt, the type system gets confused.
  for row in levels.mitems: # Iterate over var elements
    row.applyIt(it + 1)

## Increment a list of locations.
proc increment(levels: var LevelsGrid, locations: seq[Point]) =
  for point in locations:
    levels[point.row][point.col].inc(1)

## Detect and iterate over all dumbos ready to flash
iterator flashers(levels: LevelsGrid): Point =
  for r, row in enumerate(levels):
    for c, v in enumerate(row):
      if v > 9:
        yield (r, c)

## A single step through the simulation. Returns total number of flashes that occurred.
proc step(levels: var LevelsGrid): int =
  levels.increment()

  var all_flashers: HashSet[Point]
  var bang: bool = false

  while true:
    bang = false
    var round: HashSet[Point]

    for loc in levels.flashers:
      # Each dumbo flashes AT MOST ONCE per step. Skip if flashed already.
      if loc in all_flashers:
        continue

      all_flashers.incl(loc)
      # We're not modifying levels while iterating. Collect locations to flash later.
      round.incl(loc)
      bang = true

    # We're done iterating. Now increment energy around the flash locations.
    for loc in round:
      levels.increment(levels.neighbors(loc))

    # If no more dumbos flashed this round, we're done
    if not bang: break

  show levels
  # For each dumbo that flashed, set energy level to zero
  for flasher in all_flashers:
    levels[flasher.row][flasher.col] = 0

  return len(all_flashers)


show levels

var total_count = 0
for i in 1..num_turns:
  # Animated:
  stdout.eraseScreen()
  echo "Step " & $i
  let flash_count = step(levels)
  # Part 2:
  # if flash_count == 100:
  #   break
  total_count += flash_count
  # Animated:
  sleep(200)

dump total_count
