import std/[sugar, strutils, os, sequtils, options, sets, algorithm, math]

type
  Grid[T] = seq[seq[T]]
  Point = tuple[r: int, c: int]

func at[T](grid: Grid[T], r: int, c: int): Option[T] =
  try:
    return some(grid[r][c])
  except IndexDefect:
    return none(T)

func at[T](grid: Grid[T], point: Point): Option[T] =
  at(grid, point.r, point.c)

func neighbor_locations[T](grid: Grid[T], r: int, c: int): seq[Point] =
  @[(r - 1, c), (r + 1, c), (r, c - 1), (r, c + 1)]

func neighbors[T](grid: Grid[T], r: int, c: int): seq[T] =
  let raw = grid.neighbor_locations(r, c).map(point => grid.at(point))
  raw.filterIt(it.isSome).mapIt(it.get()).toSeq()

let input_file = open(paramStr(1))

let grid: Grid[int] = collect:
  for line in input_file.lines():
    toSeq(line).map((ch) => ord(ch) - ord('0'))

var risk = 0
var minima: seq[Point]

for r in 0..<len(grid):
  let row = grid[r]
  for c in 0..<len(row):
    let pt: int = grid.at(r, c).get()
    let neigh = grid.neighbors(r, c)
    if pt < min(neigh):
      risk += pt + 1
      minima.add((r, c))

dump risk


# Second part:
# 1. collect the minima locations.
# 2. for each of the locations: initialize the basin as a set containing that location.
# 3. take all four neighbors of this location.
#    if beyond edge, do nothing.
#    if a 9, do nothing.
#    if already in the set, do nothing.
#    otherwise, add this location to the set and recurse with its neighbors.
# 4. finally, return the size of this basin set.
# 5. collect sizes of all basins, sort reversed, grab first 3, product.

proc expand_basin(grid: Grid[int], basin: var HashSet[Point], origin: Point) =
  for point in grid.neighbor_locations(origin.r, origin.c):
    if point in basin: continue
    let v = grid.at(point.r, point.c)
    if v.isNone or v.get() == 9: continue
    basin.incl(point)
    expand_basin(grid, basin, point)


var basin_sizes = collect:
  for origin in minima:
    var basin = initHashSet[Point]() # NOTE: origin not included. However, it will be added during recursion.
    expand_basin(grid, basin, origin)
    len(basin)

basin_sizes.sort(order = SortOrder.Descending)
dump basin_sizes

dump prod(basin_sizes[0..2])
