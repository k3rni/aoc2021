import std/[sugar, bitops, sequtils, enumerate, strutils]

type
  BitStreamMSB* = ref object
    buf: string
    length: uint
    read_head: uint

proc parseHex*(hex_string: string): BitStreamMSB =
  let length = len(hex_string) div 2 # In bytes

  return BitStreamMSB(buf: parseHexStr(hex_string),
                      length: uint(length) * 8, # in bits
                      read_head: 0)

proc parseHex*(hex_string: string, bit_length: uint): BitStreamMSB =
  return BitStreamMSB(buf: parseHexStr(hex_string),
                      length: bit_length, # in bits
                      read_head: 0)

func `$`*(bitstream: BitStreamMSB): string =
  var s = bitstream.buf.map(x => toBin(ord(x), 8)).join("")
  s.insert("^", bitstream.read_head)
  s & "[" & $(bitstream.length) & "]"

# Read a small number of bits (not more than however many an uint holds)
# NOTE: horribly unoptimized, reads a single bit at a time
proc read*(bitstream: BitStreamMSB, count: uint): uint =
  for i in 0..<count:
    if bitstream.read_head >= bitstream.length:
      return result
    var (byte_offset, bit_offset) = (bitstream.read_head div 8, bitstream.read_head mod 8)
    var b = ord(bitstream.buf[byte_offset])
    var bit = uint(b shr (7 - bit_offset) and 1)
    result = (result shl 1) or bit
    bitstream.read_head += 1u

# Read any number of bits (truncating at the end), and make a new BitStreamMSB out of that
proc extract*(bitstream: BitStreamMSB, count: uint): BitStreamMSB =
  var c: uint = 0
  var bytes: seq[char] = collect:
    while c < count:
      let t: uint = if (count - c) >= 8:
                      8u
                    else:
                      count - c # min,max aren't defined on uints
      c += t
      let r = uint8(bitstream.read(t))
      if t < 8:
        chr(r shl (8 - t)) # Shift shorter values to the msb position
      else:
        chr(r)
  # Roundtrip through hex
  parseHex(toHex(bytes.join("")), count)

func eof*(bitstream: BitStreamMSB): bool = bitstream.read_head >= bitstream.length

if isMainModule:
  let bs = parseHex("D2FE28")
  dump bs
  echo "read 3"
  dump bs.read(3)
  dump bs
  echo "read 3 again"
  dump bs.read(3)
  dump bs
  dump bs.extract(12)
  dump bs
