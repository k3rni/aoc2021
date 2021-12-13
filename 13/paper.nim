import std/[sugar, os, sets, strutils, sequtils, math]

type
  Dot = tuple[x: int, y: int]
  Paper = HashSet[Dot]

let input_file = open(paramStr(1))
var paper: Paper
for line in lines(input_file):
  if line == "": break
  let coords = line.split(",").map(parseInt)
  paper.incl((x: coords[0], y: coords[1]))

var folds: seq[string]
for line in lines(input_file):
  if line == "": break
  folds &= line


proc fold_x(paper: var Paper, horiz: int): Paper =
  paper.map(proc(dot: Dot): Dot =
                let d = dot.x - horiz
                ((if dot.x > horiz: horiz - d else: dot.x), dot.y)
  )

proc fold_y(paper: var Paper, vert: int): Paper =
  paper.map(proc(dot: Dot): Dot =
                let d = dot.y - vert
                (dot.x, (if dot.y > vert: vert - d else: dot.y))
  )

dump folds
dump paper
dump len(paper)

for instruction in folds:
  let insn = instruction.split("=")
  let arg = parseInt(insn[1])

  echo insn
  if insn[0] == "fold along x":
    paper = paper.fold_x(arg)
  elif insn[0] == "fold along y":
    paper = paper.fold_y(arg)
  dump paper
  dump len(paper)

# Now go graph it as a scatter graph in an environment of your choice. Remember to invert the y axis: y=0 is the top row
for dot in paper:
  let (x, y) = dot
  echo $x & "," & $y
