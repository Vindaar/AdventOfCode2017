import sequtils, strutils, algorithm, unittest, times, sets, typetraits

proc parse_port(port: string): (int, int) =
  let p = port.split('/')
  result = (parseInt(p[0]), parseInt(p[1]))

template get_end(port: (int, int), p: int): int =
  # returns the 'end' of the port given `p` as the
  # start
  if port[0] == p:
    port[1]
  else:
    port[0]

proc add_port(bridge: var seq[(int, int)], port: (int, int)) =
  let end_p = bridge[bridge.high]
  if end_p[1] != port[0] and end_p[1] != port[1]:
    echo "Warning, unsuitable port! ", end_p, " ", port
  else:
    let
      in_p = if port[0] == end_p[1]: port[0] else: port[1]
      out_p = if port[0] != end_p[1]: port[0] else: port[1]
      p = (in_p, out_p)
    bridge.add(p)

proc build_bridges(bridges: seq[seq[(int, int)]],
                   port_set: HashSet[(int, int)]): seq[seq[(int, int)]] =
  result = newSeq[seq[(int, int)]]()
  for bridge in bridges:
    # given last element in bridge, append new element to this bridge
    let end_p = bridge[bridge.high]
    var port_set_mut = port_set
    while len(port_set_mut) > 0:
      var fitting_ports = filterIt(toSeq(port_set_mut.items),
                                   if it[0] == end_p[1] or it[1] == end_p[1]: true else: false)
      if len(fitting_ports) == 0:
        break
      for port in fitting_ports:
        var mbridge = bridge
        add_port(mbridge, port)
        result.add(mbridge)
        port_set_mut.excl(port)
        result.add(build_bridges(@[mbridge], port_set_mut))
        port_set_mut.incl(port)
      for port in fitting_ports:
        port_set_mut.excl(port)
      
proc build_strongest_bridge(input: seq[string], part2 = false): int =
  var ports = mapIt(input, parse_port(it))
  # all ports with a 0 on one end can act as start of
  # the bridge
  var start_ports = filterIt(ports, if it[0] == 0 or it[1] == 0: true else: false)
  var port_set = ports.toSet()

  var bridges: seq[seq[(int, int)]] = @[]
  for port in start_ports:
    let connect_to = get_end(port, 0)
    # remove port from port_set
    let p = (0, connect_to)
    bridges.add(@[p])
    port_set.excl(port)

  let all_bridges = build_bridges(bridges, port_set)
  if part2 == false:
    let lengths = mapIt(all_bridges, foldl(it, a + b[0] + b[1], 0))
    result = max(lengths)
  else:
    let
      max_lengths = mapIt(all_bridges, len(it))
      longest_bridges = filterIt(all_bridges,
                                 it.len == max(max_lengths))
    result = max(mapIt(longest_bridges, foldl(it, a + b[0] + b[1], 0)))

proc run_tests() =
  const input1 = """
0/2
2/2
2/3
3/4
3/5
0/1
10/1
9/10
"""
  check: build_strongest_bridge(input1.strip.splitLines) == 31
  check: build_strongest_bridge(input1.strip.splitLines, true) == 19  
  
proc run_input() =
  let t0 = epochTime()
  const input = slurp("input.txt").strip.splitLines
  let strongest_bridge = build_strongest_bridge(input)
  let longest_bridge = build_strongest_bridge(input, true)
    
  echo "(Part 1): The strongest possible bridge = ", strongest_bridge
  echo "(Part 2): The longest bridge is this strong = ", longest_bridge
  echo "Solutions took $#" % $(epochTime() - t0)
  
proc main() =
  run_tests()
  echo "All tests passed successfully. Result is (probably) trustworthy."
  run_input()
  
when isMainModule:
  main()
