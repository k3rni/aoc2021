import std/[sugar, os, strutils, sequtils, options, tables, enumerate]
import graphs

# Adjust to the input file you're using: the easy example is 10x10
const height = 100
const width = 100
let input_file = open("dangerous.txt")

type GridNode = tuple[r: int, c: int]

var nodes: array[height, array[width, uint]]

for r, line in enumerate(lines(input_file)):
  for c, ch in enumerate(line):
    nodes[r][c] = uint(ord(ch) - ord('0'))

proc get_nodes(): seq[GridNode] =
  collect:
    for row in 0..<height:
      for col in 0..<width:
        (row, col)


# Could also be an iterator, but that would have to be encoded in the Graph object
proc grid_neighbors(node: GridNode): seq[GridNode] =
  let (r,  c) = node
  let four_sides = @[(r - 1, c), (r, c + 1), (r + 1, c), (r, c - 1)]
  return collect:
    for candidate in four_sides:
      let (cr, cc) = candidate
      if cr < 0 or cr >= height:
        continue
      if cc < 0 or cc >= width:
        continue
      candidate

proc entry_cost(a: GridNode, b: GridNode): uint = nodes[b.r][b.c]

const tile_x = 5
const tile_y = 5

proc tiled_nodes(): seq[GridNode] =
  collect:
    for row in 0..<(height * tile_y):
      for col in 0..<(width * tile_x):
        (row, col)

proc tiled_neighbors(node: GridNode): seq[GridNode] = 
  # Almost the same as non-tiled version, but checks against proper bounds
  let (r,  c) = node
  let four_sides = @[(r - 1, c), (r, c + 1), (r + 1, c), (r, c - 1)]
  return collect:
    for candidate in four_sides:
      let (cr, cc) = candidate
      if cr < 0 or cr >= tile_y * height: continue
      if cc < 0 or cc >= tile_x * width: continue
      candidate

proc tiled_cost(a: GridNode, b: GridNode): uint =
  let (tile_row, y) = (b.r div height, b.r mod height)
  let (tile_col, x) = (b.c div width, b.c mod width)

  let cost = nodes[y][x] + uint(tile_row + tile_col)
  if cost > 9: cost - 9 else: cost

# Use this for a non-tiling graph (or set tile_x and tile_y to 1)
# let simple_graph = Graph[GridNode](get_nodes: get_nodes, get_neighbors: grid_neighbors, edge_length: entry_cost)

dump tiled_cost((0, 0), (0, 10))

let tiled_graph = Graph[GridNode](get_nodes: tiled_nodes, get_neighbors: tiled_neighbors, edge_length: tiled_cost)

let start: GridNode = (0, 0)
# let target: GridNode = (height - 1, width - 1)
let target: GridNode = (tile_y * height - 1, tile_x * width - 1)

let (dist, prev) = dijkstra(tiled_graph, start)

let path = reconstruct_path(prev, start, target)
let values_at_path = path.map((n) => tiled_cost(start, n))

# Helps diagnosing path issues
# dump path
# dump values_at_path
let total_cost = path.foldl(a + tiled_cost(start, b), 0u) - tiled_cost(start, start)
dump total_cost
