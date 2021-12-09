import std/[sugar, sequtils, strutils, os, tables]

# Usage:
# nim r lanternfish.nim INPUT_FILE NUM_DAYS

proc multiply_fish(fish: var openArray[int]) =
  let ready = fish[0]
  # Fish reset to stage 6 after spawning offspring. Setting 7 because it's later moved to 6.
  fish[7] += ready
  for i in 0..7:
    fish[i] = fish[i+1]
  # New spawns start at stage 8. Must be added here, after the other stages are recalculated.
  fish[8] = ready

# A simple sum operation. Note that foldl is a macro, with special syntax for its 2nd argument:
# it doesn't take a proc, but an expression which must use names a and b.
func count_fish(fish: openArray[int]): int = foldl(fish, a + b, 0)

# The fish can be represented as just an array, where index i is the count of fish at life stage i.
# Given an initial vector of 3,4,3,1,2 this translates to:
# [ 0, 1, 1, 2, 1, 0, 0, 0, 0 ]
# This is also key to solving the second part, as holding the entire list in memory would be impossible.
var fish: array[0..8, int] # An array can use any arbitrary range as its indexes (e.g. start from 1)
let input_file = open(paramStr(1))
for el in input_file.readLine().split(",").map(parseInt):
  fish[el] += 1

let numdays = parseUint(paramStr(2))

echo "Initial state"
dump fish
let sum = count_fish(fish)
dump sum

for day in 1..numdays:
   echo "Day " & $day
   multiply_fish(fish)
   dump fish
   let sum = count_fish(fish)
   dump sum
