import std/[sugar, tables, heapqueue, sequtils]

type
  DijkstraResult*[N] = tuple[dist: Table[N, uint], prev: Table[N, N]]
  Graph*[N] = object
    get_nodes*: () -> seq[N]
    get_neighbors*: (N) -> seq[N]
    edge_length*: (a: N, b: N) -> uint
  Pair[N] = tuple[node: N, dist: uint]

const INFTY = high(uint)

proc `==`[N](a, b: Pair[N]): bool = a.node == b.node

proc `<`[N](a, b: Pair[N]): bool = a.dist < b.dist


proc dijkstra*[N](graph: Graph[N], source: N): DijkstraResult[N] =
  var dist: Table[N, uint]
  var prev: Table[N, N]
  var queue: HeapQueue[Pair[N]]

  dist[source] = 0
  queue.push((node: source, dist: 0u))
  # This version doesn't front-load everything into the priority queue

  while len(queue) > 0:
    echo $(len(queue))
    let (u, _) = queue.pop() # extract_min
    for v in graph.get_neighbors(u):
      let alt = dist.getOrDefault(u, INFTY) + graph.edge_length(u, v)
      if alt < dist.getOrDefault(v, INFTY):
        dist[v] = alt
        prev[v] = u

        let index = queue.find((node: v, dist: INFTY)) # Uses the `==` operator which doesn't compare dists
        if index != -1:
          queue.del(index)

        queue.push((node: v, dist: alt))

  return (dist, prev)

proc reconstruct_path*[N](prev: Table[N, N], source: N, target: N): seq[N] =
  var s: seq[N]
  var u = target
  if not (u in prev) or u == source:
    raise newException(ValueError, "Cannot find path")

  while true:
    s.insert(u, 0)
    if not (u in prev) or u == source:
      return s
    u = prev[u]
