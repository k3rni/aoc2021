import std/[sugar, sequtils, strutils, os]

# Usage:
# nim r crabs.nim INPUT_FILE

# This is the first part, where the cost is just the delta in positions.
func calculate_costs(crabs: openArray[int], desired_position: int): int =
  crabs.foldl(a + abs(b - desired_position), 0)

# For the second part, note that he cost function is now this sequence (OEIS: A000217)
func triangular_number(n: int): int = n * (n + 1) div 2 # div is integer division, / is float

func calculate_costs_2(crabs: openArray[int], desired_position: int): int =
  crabs.foldl(a + triangular_number(abs(b - desired_position)), 0)

let input_file = open(paramStr(1))
let crabs = input_file.readLine().split(",").map(parseInt)

let (min_position, max_position) = (min(crabs), max(crabs))

let costs = (min_position..max_position).mapIt(calculate_costs_2(crabs, it))
let cheapest = min(costs)
let position = costs.minIndex()

dump @[cheapest, position]
