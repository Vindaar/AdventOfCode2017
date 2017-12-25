import sequtils, strutils, algorithm, unittest, times, sets, math, sets, tables, future

const
  # down and up are reversed intuitively, because we start
  # at the top and go down, which means /increasing/ the index
  # for y
  DOWN  = (0, 1)
  UP    = (0, -1)
  RIGHT = (1, 0)
  LEFT  = (-1, 0)

proc `$$`(grid: Table[(int, int), char]): string =
  # pretty print the grid
  # Damn, only works on non-modified grids. Besides sorting the
  # keys, we'd need to get min and max and fill non available
  # keys with '.'. So screw it...
  result = "\n"
  let edgesize = int(sqrt(float((grid.len))))
  let keys_grid = sortedByIt(toSeq(keys(grid)), (it[1], it[0]))
  var i = 0
  for y in 0..<edgesize:
    var line = ""
    for x in 0..<edgesize:
      line &= $grid[keys_grid[i]]
      inc i
    line &= "\n"
    result &= line

proc create_starting_grid(input: seq[string]): Table[(int, int), char] =
  result = initTable[(int, int), char]()
  for y, line in input:
    for x, node in line:
      result[(x, y)] = node

proc turn_left(dir: (int, int)): (int, int) =
  if dir == UP:
    result = LEFT
  elif dir == LEFT:
    result = DOWN
  elif dir == DOWN:
    result = RIGHT
  else:
    result = UP

proc turn_right(dir: (int, int)): (int, int) =
  if dir == UP:
    result = RIGHT
  elif dir == RIGHT:
    result = DOWN
  elif dir == DOWN:
    result = LEFT
  else:
    result = UP

template part1_logic(node: char, dir: (int, int), grid: Table[(int, int), char]) =
  case node
  of '.':
    # empty node, turn left, infect 
    dir = turn_left(dir)
    grid[(x, y)] = '#'
    inc result
  of '#':
    # infected node, turn right, clean 
    dir = turn_right(dir)
    grid[(x, y)] = '.'
  else:
    echo "Does not happen"
    discard

template part2_logic(node: char, dir: (int, int), grid: Table[(int, int), char]) =
  case node
  of '.':
    # empty node, turn left, weaken node
    dir = turn_left(dir)
    grid[(x, y)] = 'W'
  of 'W':
    # weakened node, don't turn, infect
    grid[(x, y)] = '#'
    inc result
  of '#':
    # infected node, turn right, clean 
    dir = turn_right(dir)
    grid[(x, y)] = 'F'
  of 'F':
    # flagged node, reverse, clean
    dir = (-1 * dir[0], -1 * dir[1])
    grid[(x, y)] = '.'
  else:
    echo "Does not happen"
    discard

proc calc_infections(input: seq[string], part2 = false): int =
  let center = len(input) div 2
  echo "Center index is $# / $# " % [$center, $center]
  var grid = create_starting_grid(input)
  echo "Starting grid looks like:"
  echo $$grid
  let start = (center, center)

  var bursts = 0
  if part2 == true:
    bursts = 10_000_000
  else:
    bursts = 10_000
  
  var
    dir = UP
    x = start[0]
    y = start[1]
  for i in 0..<bursts:
    if hasKey(grid, (x, y)) == false:
      grid[(x, y)] = '.'      
    let node = grid[(x, y)]
    if part2 == false:
      part1_logic(node, dir, grid)
    else:
      part2_logic(node, dir, grid)
    # perform move
    x += dir[0]
    y += dir[1]

proc run_tests() =
  const input1 = """
..#
#..
...
"""
  check: calc_infections(input1.strip.splitLines) == 5587
  check: calc_infections(input1.strip.splitLines, true) == 2511944

proc run_input() =
  let t0 = epochTime()
  const input = slurp("input.txt").strip.splitLines
  let infections = calc_infections(input)
  let infections_mut = calc_infections(input, true)  
  
  echo "(Part 1): The number of infections after 10,000 bursts is = ", infections
  echo "(Part 2): The number of infections of the mutated virus is = ", infections_mut
  echo "Solutions took $#" % $(epochTime() - t0)
  
proc main() =
  run_tests()
  echo "All tests passed successfully. Result is (probably) trustworthy."
  run_input()
  
when isMainModule:
  main()
