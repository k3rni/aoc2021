import std/[strutils, os, re]

# Usage:
# nim r navigation_aim INPUT_FILE

let COMMANDS = re"^(forward|down|up)\s+(\d+)"

let input_file = open(os.paramStr(1))

var (depth, horiz, aim) = ( 0, 0, 0)

for line in lines(input_file):
  var args: array[2, string]
  if match(line, COMMANDS, args):
    let amt = parseInt(args[1])
    echo "command=$1 arg=$2" % args
    case args[0]
    of "forward":
      horiz += amt
      depth += amt * aim
    of "down":
      aim += amt
    of "up":
      aim -= amt
    else: echo "Unknown command $1 $2" % args
    echo format("D=$1 H=$2 A=$3", depth, horiz, aim)

echo depth * horiz


