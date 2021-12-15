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

# Concept for part 2
# Think in terms of counts of pairs:
# The initial NNCB contains three pairs: NN, NC, CB, so the initial counts dict is {NN=>1, NC=>1, CB=>1}
# The first expansion step expands NN to NCN, NC to NBC, CB to CHB
# Split these into pairs again: NC, CN, NB, BC, CH, HB, each once
# The next step gives us NC => NBC, CN => CCN, NB => NBB, BC => BBC, CH => CBH, HB => HCB
# In terms of pairs this is NB, BC, CC, CN, NB, BB, BB, BC, CB, BH, HC, CB
# Resulting in counts of {NB=>2, BC=>2, CC=>1, CN=>1, BB=>2, CB=>2, BH=>1, HC=>1}
# The next expansion of NB=>2 produces two instances of NBB, so adds two more of NB and BB
# et caetera

proc expand(pair_counts: var CountTable[string], expansion_map: Expansion) =
  var new_counts = initCountTable[string]()
  for key, count in pair_counts.pairs():
    # For each pair that results from expanding this one, add n expanded pairs
    # echo "Old key " & $key & " with count " & $count
    let insertion = expansion_map[key]
    let left = key[0] & insertion
    let right = insertion & key[1]
    # echo "New key " & $left & " with count " & $count
    # echo "New key " & $right & " with count " & $count
    new_counts.inc(left, count)
    new_counts.inc(right, count)
  pair_counts.clear()
  pair_counts.merge(new_counts)
  dump pair_counts


var pair_counts = toCountTable(toSeq(each_cons(initial_template, 2)))

dump pair_counts
for i in 1..num_steps:
  echo "Step " & $i
  expand(pair_counts, expansion_map)

func count_individual_letters(pair_counts: var CountTable[string]): CountTable[char] =
  var counts = initCountTable[char]()
  for key, value in pair_counts.pairs:
    # counts.inc(key[0], value)
    # Why is skipping key[0] correct? :thinking-face:
    counts.inc(key[1], value)
  counts
 
let counts = count_individual_letters(pair_counts)
let (top, bottom) = (largest(counts), smallest(counts))

echo "Most common is " & $(top.key) & " with " & $(top.val) & " occurrences"
echo "Least common is " & $(bottom.key) & " with " & $(bottom.val) & " occurrences"

echo "The difference is " & $(top.val - bottom.val)
