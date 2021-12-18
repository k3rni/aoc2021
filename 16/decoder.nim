import std/[sugar, os, strutils, sequtils, tables]
import bitstream

type
  Packet = ref object of RootObj
    version: uint8
  LiteralPacket = ref object of Packet
    value: int64
  OperatorPacket = ref object of Packet
    operator: uint8
    packets: seq[Packet]

let opsmap: Table[uint, string] = toTable({0u: "sum", 1u: "prod", 2u: "min", 3u: "max", 5u: "gt", 6u: "lt", 7u: "eq"})

method toString(packet: Packet): string {.base.} = "Packet(version=" & $(packet.version) & ")"
method toString(packet: LiteralPacket): string = "LiteralPacket(version=" & $(packet.version) & ", value=" & $(packet.value) & ")"
method toString(packet: OperatorPacket): string =
  ("OperatorPacket(" &
    "version=" & $(packet.version) &
    ", operator=" & $(packet.operator) & " or " & opsmap[packet.operator] &
    ", packet_count=" & $(len(packet.packets)) &
    ", packets=" & (packet.packets.map(x => toString(x)).join(";")) &
    ")")

# let input = "C0015000016115A2E0802F182340"
# let input = "9C0141080250320F1802104A08"
# let input = "04005AC33890"
let input = "8054F9C95F9C1C973D000D0A79F6635986270B054AE9EE51F8001D395CCFE21042497E4A2F6200E1803B0C20846820043630C1F8A840087C6C8BB1688018395559A30997A8AE60064D17980291734016100622F41F8DC200F4118D3175400E896C068E98016E00790169A600590141EE0062801E8041E800F1A0036C28010402CD3801A60053007928018CA8014400EF2801D359FFA732A000D2623CADE7C907C2C96F5F6992AC440157F002032CE92CE9352AF9F4C0119BDEE93E6F9C55D004E66A8B335445009E1CCCEAFD299AA4C066AB1BD4C5804149C1193EE1967AB7F214CF74752B1E5CEDC02297838C649F6F9138300424B9C34B004A63CCF238A56B71520142A5A7FC672E5E00B080350663B44F1006A2047B8C51CC80286C0055253951F98469F1D86D3C1E600F80021118A124261006E23C7E8260008641A8D51F0C01299EC3F4B6A37CABD80252211221A600BC930D0057B2FAA31CDCEF6B76DADF1666FE2E000FA4905CB7239AFAC0660114B39C9BA492D4EBB180252E472AD6C00BF48C350F9F47D2012B6C014000436284628BE00087C5D8671F27F0C480259C9FE16D1F4B224942B6F39CAF767931CFC36BC800EA4FF9CE0CCE4FCA4600ACCC690DE738D39D006A000087C2A89D0DC401987B136259006AFA00ACA7DBA53EDB31F9F3DBF31900559C00BCCC4936473A639A559BC433EB625404300564D67001F59C8E3172892F498C802B1B0052690A69024F3C95554C0129484C370010196269D071003A079802DE0084E4A53E8CCDC2CA7350ED6549CEC4AC00404D3C30044D1BA78F25EF2CFF28A60084967D9C975003992DF8C240923C45300BE7DAA540E6936194E311802D800D2CB8FC9FA388A84DEFB1CB2CBCBDE9E9C8803A6B00526359F734673F28C367D2DE2F3005256B532D004C40198DF152130803D11211C7550056706E6F3E9D24B0"

# Forward declaration
proc parse_stream(stream: BitStreamMSB): seq[Packet]

proc parse_literal(version: uint, stream: BitStreamMSB): LiteralPacket =
  var payload: int64
  while true:
    let clump: uint = stream.read(5)
    dump toBin(int(clump), 5)
    payload = (payload shl 4) or int64(clump and 0xF)
    dump toBin(payload, 64)
    let flag = clump shr 4
    dump flag
    if flag == 0:
      break

  echo "lit(" & $version & "," & $payload & ")"
  return LiteralPacket(version: uint8(version), value: int64(payload))

proc parse_operator(version: uint, type_id: uint, stream: BitStreamMSB): OperatorPacket =
  let mode = stream.read(1)
  echo "op(" & $type_id & ")"
  dump stream
  if mode == 0:
    let length = stream.read(15)
    echo "Mode 0 packet with substream of length " & $length
    dump stream
    let substream = stream.extract(length)
    return OperatorPacket(version: uint8(version), operator: uint8(type_id), packets: parse_stream(substream))
  elif mode == 1:
    let count = stream.read(11)
    echo "Mode 1 packet with " & $count & " subpackets"
    dump stream
    let subpackets = collect:
      for i in 1..count:
        let version = stream.read(3)
        let typeid = stream.read(3)
        case typeid:
          of 4:
            parse_literal(version, stream)
          else:
            parse_operator(version, type_id, stream)
    return OperatorPacket(version: uint8(version), operator: uint8(type_id), packets: subpackets)

proc parse_input(input: string): seq[Packet] =
  var bs = parseHex(input)
  return parse_stream(bs)

proc parse_stream(stream: BitStreamMSB): seq[Packet] = 
  var packets: seq[Packet]

  while not stream.eof():
    dump stream
    let version = stream.read(3)
    echo "Read version: " & $version
    # if version == 0: break
    let typeid = stream.read(3)
    echo "Read typeid: " & $typeid
    dump stream
    case typeid:
      of 4:
        echo "Parsing as literal"
        packets &= parse_literal(version, stream)
      else:
        echo "Parsing as operator"
        packets.add(parse_operator(version, type_id, stream))
  return packets


method sum_version_numbers(root: Packet): uint {.base.} = root.version
method sum_version_numbers(root: LiteralPacket): uint = root.version
method sum_version_numbers(root: OperatorPacket): uint = root.version + root.packets.foldl(a + b.sum_version_numbers(), 0u)

func padding(size: int): string =
  return repeat("  ", size) & "> "

method evaluator(packet: Packet, nest: int = 0): int64 {.base.} =
  raise newException(IndexDefect, "Evaluating base " & toString(packet))
method evaluator(packet: LiteralPacket, nest: int = 0): int64 =
  echo padding(nest) & toString(packet)
  packet.value
method evaluator(root: OperatorPacket, nest: int = 0): int64 =
  echo padding(nest) & toString(root)
  case root.operator:
    of 0: # SUM
      let v: int64 = root.packets.foldl(a + evaluator(b, nest + 1), 0i64)
      echo padding(nest) & $v
      return v
    of 1: # PROD
      let v: int64 = root.packets.foldl(a * evaluator(b, nest + 1), 1i64)
      echo padding(nest) & $v
      return v
    of 2: # MIN
      let values: seq[int64] = root.packets.map(p => evaluator(p, nest + 1))
      let v = min(values)
      echo padding(nest) & $v
      return v
    of 3: # MAX
      let values: seq[int64] = root.packets.map(p => evaluator(p, nest + 1))
      let v = max(values)
      echo padding(nest) & $v
      return v
    # of 4: Literals
    of 5: # GT
      let left: int64 = evaluator(root.packets[0], nest + 1)
      let right: int64 = evaluator(root.packets[1], nest + 1)
      let v = if left > right: 1 else: 0
      echo padding(nest) & $v
      return v
    of 6: # LT
      let left: int64 = evaluator(root.packets[0], nest + 1)
      let right: int64 = evaluator(root.packets[1], nest + 1)
      let v = if left < right: 1 else: 0
      echo padding(nest) & $v
      return v
    of 7: # EQ
      let left: int64 = evaluator(root.packets[0], nest + 1)
      let right: int64 = evaluator(root.packets[1], nest + 1)
      let v = if left == right: 1 else: 0
      echo padding(nest) & $v
      return v
    else:
      raise newException(IndexDefect, "Evaluating unknown operator=" & $(root.operator))


if isMainModule:
  let packets = parse_input(input)
  # for pkt in packets:
  #   echo toString(pkt)
    # dump sum_version_numbers(pkt)
  dump evaluator(packets[0])

