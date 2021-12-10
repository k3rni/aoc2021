import std/[sugar, strutils, sequtils, os, options, tables, enumerate, algorithm]

# Usage:
# nim r syntax INPUT_FILE
# To run either part, flip conditions on the `when` statements.

let lines = toSeq(lines(open(paramStr(1))))

# Matching parens is a task done with the stack. Nim's seqs have .add() and .pop() which are suitable

let matching_pairs = {'[': ']', '{': '}', '(': ')', '<': '>'}.toTable()
let openers = toSeq(matching_pairs.keys)

type
  Corrupted = tuple[expected: char, actual: char, pos: int]
  Stack = seq[char]

# Return the mismatched ending character, or none if line was valid
# stack_out will capture the state of opener stack, used for the second part
# NOTE: the full Corrupted is overkill. For scoring, the `actual` field alone would be enough. Was useful for debugging.
proc check_line(line: string, stack_out: ref Stack = nil): Option[Corrupted] =
  var stack = newSeq[char]()
  for i, ch in enumerate(line):
    if ch in openers:
      stack &= ch
      continue

    let closer = matching_pairs[stack[^1]]
    if closer != ch:
      return some((closer, ch, i))
    else:
      discard stack.pop()
  if not stack_out.isNil: # Only update if our caller really cares about it
    stack_out[0..^1] = stack
  return none[Corrupted]()


### Part 1

when false:
  var counts = initCountTable[char]()
  for line in lines:
    # Not passing stack. This is safe - a nil check is performed in line 29
    let result = check_line(line)
    if result.isSome:
      let (_, actual, _) = result.get()
      counts.inc(actual, 1)

  let total = counts[')'] * 3 + counts[']'] * 57 + counts['}'] * 1197 + counts['>'] * 25137
  dump total

### End of Part 1

### Part 2

func score_completion(completion: string): int =
  # NOTE: hidden base-5 number here. The closing symbols are digits
  completion.foldl(5 * a + " )]}>".find(b), 0)

when true:
  var stack = Stack.new()
  var scores = collect:
    for line in lines:
      let result = check_line(line, stack)
      if result.isSome: continue
      # The completion is just our stack, reversed and changed to contain closing symbols
      let completion = stack[].map(c => matching_pairs[c]).reversed().join("")
      dump @[line, completion]
      let score = score_completion(completion)
      dump score
      score

  scores.sort()
  dump scores
  dump scores[len(scores) div 2]

### End of Part 2
