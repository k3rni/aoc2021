import std/[sugar, os, tables, strutils, sequtils]

type Expansion = Table[string, char]

let input = open(paramStr(1))
let num_steps = parseInt(paramStr(2))

let initial_template = input.readLine().strip()
discard input.readLine()
var expansion_map: Expansion = collect:
  for line in lines(input):
    let parts = line.split(" -> ")
    { parts[0]: parts[1][0] }


iterator each_cons(str: string, chunk_size: int): string =
  let length = len(str)
  for i in 0..(length - chunk_size):
    let (chunk_start, chunk_end) = (i, i + chunk_size - 1)
    yield str[chunk_start..chunk_end]

proc expand(expansion_map: Expansion, initial: string): string =
  let length = len(initial)
  let cons: seq[string] = toSeq(each_cons(initial, 2))
  let mapped = cons.map(s => expansion_map[s] & s[1])
  initial[0] & mapped.join("")

dump initial_template
dump expansion_map

var code = initial_template
# dump code
for i in 1..num_steps:
  echo "Step " & $i
  code = expand(expansion_map, code)
  # dump code

let counts = newCountTable[char](code)
let (top, bottom) = (largest(counts), smallest(counts))

echo "Most common is " & $(top.key) & " with " & $(top.val) & " occurrences"
echo "Least common is " & $(bottom.key) & " with " & $(bottom.val) & " occurrences"

echo "The difference is " & $(top.val - bottom.val)
