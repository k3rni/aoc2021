import std/[sugar, sequtils, strutils, os, bitops]
from std/parseutils import parseBin

const WIDTH = 12

iterator load_binary_numbers(f: File): int =
  for line in lines(f):
    var n: int
    let bin_chars = parseBin(line, n)
    if bin_chars > 0:
      yield n

func binary_list(numbers: seq[int]): seq[string] = collect:
  for num in numbers:
    toBin(num, WIDTH)

proc find_common_bit(numbers: seq[int], pos: uint): uint8 =
  var zeros, ones: uint
  for num in numbers:
    if testBit(num, pos):
      ones += 1
    else:
      zeros += 1
  if ones >= zeros: 1 else: 0

func filter_by_bit(numbers: seq[int], pos: uint, bit: uint): seq[int] =
  collect:
    for num in numbers:
      if cast[uint](ord(testBit(num, pos))) == bit: num


let input_file = open(os.paramStr(1))
let numbers = toSeq(load_binary_numbers(input_file))

dump(binary_list(numbers))

dump(toSeq(filter_by_bit(numbers, 0, 0)))

proc narrow(numbers: seq[int], bit_selector: (seq[int], uint) -> uint8): int =
  var nums = deepCopy(numbers)
  for i in countdown(WIDTH - 1, 0):
    let u = cast[uint](i)
    let bit = bit_selector(nums, u)
    nums = filter_by_bit(nums, u, bit)
    if len(nums) == 1:
      return nums[0]

let oxy_rating = narrow(numbers, (a: seq[int], pos: uint) => find_common_bit(a, pos))
let co2_rating = narrow(numbers, (a: seq[int], pos: uint) => 1 - find_common_bit(a, pos))

dump [oxy_rating, co2_rating]
dump oxy_rating * co2_rating
