import strutils, sequtils, future, algorithm, times, unittest, math

# this is quite an ugly solution to day 11, since I chose the coordinate system
# somewhat badly. Didn't want to read up on hex grids, rather figure it out myself
# uses a brute forde path finding algorithm to determine the path and length
# of said path for the distance :D

type
  Step = tuple[x, y, c: float]
  Path = seq[Step]
  Paths = seq[Path]

const
  NE = (1.0'f64, 0.5'f64)
  N  = (0'f64,   1'f64)
  NW = (-1'f64,  0.5'f64)
  SW = (-1'f64,  -0.5'f64)
  S  = (0'f64,   -1'f64)
  SE = (1'f64,   -0.5'f64)
  # NE = (cos(60'f64), sin(60'f64))
  # N  = (0'f64, 1'f64)
  # NW = (-cos(60'f64), sin(60'f64))
  # SW = (-cos(60'f64), -sin(60'f64))
  # S  = (0'f64, -1'f64)
  # SE = (cos(60'f64), -sin(60'f64))

  

const
  dirs = [ NE, N, NW, SW, S, SE ]

iterator walkChild(moves: seq[string]): tuple[x, y: float] =
  for step in moves:
    case step
    of "ne": yield NE
    of "n": yield N
    of "nw": yield NW
    of "sw": yield SW
    of "s": yield S
    of "se": yield SE

proc get_dist(loc: tuple[x, y: float]): float =
  result = sqrt(pow(loc.x, 2) + pow(loc.y, 2))
    
proc dist_from_location(location: tuple[x, y: float]): int =
  # number of steps necessary to get back to (0 / 0)
  
  # first perform diagonal steps
  var
    count = 0
    loc = location

  var paths: Paths = @[]

  if len(paths) == 0:
    let st: Step = (loc.x, loc.y, get_dist(loc))
    let ss: Path = @[st]
    paths.add(ss)

  var
    full_paths: Paths = @[]
    s: Step

  var shortest_dist = min(mapIt(paths, it[^1].c))
  
  while len(paths) > 0:
    if shortest_dist == 0:
      let
        pos_paths = filterIt(paths, it[^1].c == 0)
        path_lengths = mapIt(pos_paths, len(it))
      full_paths.add(pos_paths)
      
    var cur_paths: Paths = @[]
    for i, p in paths:
      let cur_loc = p[^1]
      for d in dirs:
        s.x = cur_loc.x + d[0]
        s.y = cur_loc.y + d[1]
        s.c = get_dist((s.x, s.y))
        if s.c <= (shortest_dist):
          cur_paths.add(concat(p, @[s]))
          shortest_dist = s.c
      # now we can delete p, because we added all new elements from p outgoing
      paths.delete(i)
    paths.add(cur_paths)
    for i, p in paths:
      if p[^1].c > shortest_dist + 0.5:
        paths.delete(i)

  result = min(mapIt(full_paths, len(it))) - 1

proc calc_hex_distance(input: string, part2 = false): int =
  let moves = split(strip(input), ',')
  var
    location: tuple[x, y: float64] = (0.0, 0.0)

  var max_dists: seq[int] = @[]
  var max_val = 0.0 
  var max_dist = 0
  for step in walkChild(moves):
    location.x += step.x
    location.y += step.y
    if part2 == true:
      let current_dist = get_dist(location)
      echo location, " and dist ", current_dist
      if current_dist > max_val:
        let m_dist = dist_from_location(location)
        max_dists.add(m_dist)
  echo location
  
  if part2 == false:
    result = dist_from_location(location)
  else:
    max_dist = max(max_dists)
    echo "Position with largest euclidian distance was ", max_dist
    result = max_dist

proc run_tests() =
  const m1 = "ne,ne,ne"
  check: calc_hex_distance(m1) == 3
  const m2 = "ne,ne,sw,sw"
  check: calc_hex_distance(m2) == 0
  const m3 = "ne,ne,s,s"
  check: calc_hex_distance(m3) == 2
  const m4 = "se,sw,se,sw,sw"
  check: calc_hex_distance(m4) == 3
  const m5 = "ne,se"
  check: calc_hex_distance(m5) == 2
  
proc run_input() =

  let t0 = cpuTime()      
  const input = "input.txt"
  const child_move = slurp(input)
  let dist = calc_hex_distance(child_move)
  let max_dist = calc_hex_distance(child_move, true)  

  echo "(Part 1): The distance of the child program is = ", dist
  echo "(Part 2): The largest distance the child got is = ", max_dist
  echo "Solutions took $#" % $(cpuTime() - t0)
  
proc main() =
  run_tests()
  echo "All tests passed successfully. Result is (probably) trustworthy."
  run_input()
  
when isMainModule:
  main()
