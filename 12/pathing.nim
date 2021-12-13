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

# Closure iterators can recur https://github.com/nim-lang/Nim/issues/16876
iterator path(graph: Graph, origin: string, destination: string, route: var seq[string], nest: int = 0): seq[string] {.closure.} =
  echo padding(nest) & "Route: " & $route
  let outgoing = graph[origin]
  echo padding(nest) & "Origin: " & origin & " connects to " & $outgoing
  if origin == destination:
    echo padding(nest) & "Found path!"
    yield route

  for node in outgoing:
    if node in route:
      if small_cave(node):
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
