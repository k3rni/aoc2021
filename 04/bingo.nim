import std/[sugar, sequtils, strutils, os]

# Usage:
# nim r bingo INPUT_FILE

# This is a solution for both parts; the first part asks for the first board to win and its score,
# and the second part asks for the last board.

type BingoRow = array[5, uint]
type BingoBoard = object
  rows: array[5, BingoRow]
  marked: seq[uint]
  won: bool

func newBoard(): BingoBoard = default(BingoBoard)

# Nim's calling convention allows calling these like methods
# on a BingoBoard, which is used throughout.
proc loadRow(board: var BingoBoard, index: uint, values: openArray[uint]) =
  board.rows[index][0..4] = values[0..4]

func winning(row: openArray[uint], marked: seq[uint]): bool =
  row.all (v: uint) => v in marked

func checkBingoRows(board: BingoBoard): bool = 
  board.rows.any (row: BingoRow) => row.winning(board.marked)

func checkBingoCols(board: BingoBoard): bool =
  for col in 0..<5:
    let column = board.rows.map (row: BingoRow) => row[col]
    if column.winning(board.marked):
      return true
  return false

proc partialScore(board: BingoBoard): uint =
  var score: uint = 0
  for row in board.rows:
    for value in row:
      if not (value in board.marked):
        score += value
  return score

proc processNumber(board: var BingoBoard, num: uint): uint =
  board.marked.add(num)
  if board.checkBingoRows() or board.checkBingoCols():
    let firstRow = board.rows[0]
    echo "Bingo for board " & $`firstRow`
    let score = partialScore(board)
    return score * num
  else:
    return 0

iterator board_rows(input: File): seq[uint] {.closure.} =
  try:
    while true:
      var line = input.readLine()
      if line == "": continue
      yield line.splitWhitespace().map(parseUInt)
  except EOFError:
    return

iterator boards_from_file(input: File): BingoBoard =
  var board = newBoard()
  var i: uint = 0
  for row in board_rows(input):
    if i > 0 and i mod 5 == 0:
      yield board
      board = newBoard()
    board.loadRow(i mod 5, row)
    i += 1
  yield board

let input_file = open(os.paramStr(1))

let line = input_file.readLine()
let bingo_queue = line.split(",").map(parseUInt)


var boards = toSeq(boards_from_file(input_file))

for call in bingo_queue:
  if boards.allIt(it.won):
    echo "All boards won, game over"
    break

  echo "Calling " & $call

  for board in boards.mitems:
    if board.won:
      continue
    let s = board.processNumber(call)
    if s > 0:
      let head = board.rows[0]
      echo "Winner with score " & $s & " is board " & $head
      board.won = true
