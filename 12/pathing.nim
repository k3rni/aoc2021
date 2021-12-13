import std/[os, sequtils, sugar, tables, strutils, sets, algorithm]

let input_file = open(paramStr(1))

# Representing a graph as a table of name -> other names

type
  Adjacency = HashSet[string]
  Graph = Table[string, Adjacency]
  Visited = HashSet[string]

var graph: Graph

for line in lines(input_file):
  let items = line.split("-", 1)
  let (left, right) = (items[0], items[1])
  var ladj: Adjacency = graph.getOrDefault(left)
  ladj.incl(right)
  graph[left] = ladj
  var radj: Adjacency = graph.getOrDefault(right)
  radj.incl(left)
  graph[right] = radj


dump graph

func small_cave(name: string): bool =
  toSeq(name.items).all(isLowerAscii)

func padding(size: int): string = repeat(" ", 2 * size) & "> "

func cant_revisit(node: string, route: seq[string]): bool =
  let counts = newCountTable(route.filterIt(small_cave(it)))
  let twos = toSeq(counts.values).filterIt(it >= 2)
  # The route may already include node *once*
  # But it may not include other small caves more than once
  counts[node] > 1 or len(twos) > 0


# Closure iterators can recur https://github.com/nim-lang/Nim/issues/16876
iterator path(graph: Graph, origin: string, destination: string, route: var seq[string], nest: int = 0): seq[string] {.closure.} =
  echo padding(nest) & "Route: " & $route
  let outgoing = graph[origin]
  echo padding(nest) & "Origin: " & origin & " connects to " & $outgoing
  if origin == destination:
    echo padding(nest) & "Found path!"
    yield route

  # Cannot step out of end
  if origin == "end":
    return

  for node in outgoing:
    if node in route:
      if node == "start":
        continue # Cannot return there
      if small_cave(node) and cant_revisit(node, route): # The second condition is for Part 2
        echo padding(nest) & "Already visited: " & $node
        continue
      else:
        echo padding(nest) & "Trackback! " & $node
    route.add(node)

    echo padding(nest) & "Going to: " & $node
    let recur = path # Must assign, otherwise nim is confused about types.
    for newroute in recur(graph, node, destination, route, nest + 1):
      yield newroute
    # since there is no rfind for arrays, reverse, delete first, reverse
    route.reverse()
    route.delete(route.find(node))
    route.reverse()

  echo padding(nest) & "No paths remaining"


var route: seq[string] = @["start"]
let all_paths = collect:
  for paths in graph.path("start", "end", route):
    echo "****** " & $paths
    paths

dump all_paths
dump len(all_paths)
