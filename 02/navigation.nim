import std/[sugar, options, strutils, os, re, sequtils]

# Usage:
# nim r navigation.nim INPUT_FILE

# Note: can't be a const because weird reasons https://github.com/nim-lang/Nim/issues/14049
let COMMANDS = re"^(\w+)\s+(\d+)"

# This is a verbose solution, using types and FP.
# The second part uses a simpler, imperative approach.
# It's easy to adapt this to solve the second part: add aim to the Position tuple,
# and handle the new calculations in update_position.

type
  Position = tuple[depth: int, horiz: int]
  Word = enum forward, up, down
  Command = tuple[word: Word, arg: int]

proc parse_command(line: string): Option[Command] =
  var args: array[2, string]
  if match(line, COMMANDS, args):
    some((word: parseEnum[Word](args[0]),
          arg: parseInt(args[1])))
  else:
    none(Command)

func update_position(position: Position, command: Option[Command]): Position =
  if command.isNone:
    return position

  let (word, arg) = command.get()
  case word:
    of forward:
      (depth: position.depth, horiz: position.horiz + arg)
    of up:
      (depth: position.depth - arg, horiz: position.horiz)
    of down:
      (depth: position.depth + arg, horiz: position.horiz)

let input_file = open(os.paramStr(1))

# Collect is list comprehension: the final expression is collected into a seq.
let commands = collect:
  for line in lines(input_file):
    parse_command(line)
let final_position = commands.foldl(update_position(a, b), Position.default)
dump final_position
echo final_position.depth * final_position.horiz
