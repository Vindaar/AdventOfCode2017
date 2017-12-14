import sequtils, strutils, future, unittest, times, tables, sets, algorithm
import ../Day10/day10_combined

type
  Coord = tuple[x, y: int]

const
  RIGHT = (1, 0)
  LEFT  = (-1, 0)
  UP    = (0, 1)
  DOWN  = (0, -1)

const
  dirs = [RIGHT, LEFT, UP, DOWN]

proc calc_used_squares(keystring: string): int =
  let
    kh_input = toSeq(0..255)
    # create sequence of suffixes, calc knot hash for each string
    rows = mapIt(toSeq(0..127),
                 # for each string map every character
                 mapIt(calc_knot_hash(kh_input, (keystring & "-" & $it)),
                       # parse it from hex to int, convert int to binary of 4 bits
                       toBin(parseHexInt($it), 4)))
  # add all 1s of single string given by concatenation of all rows
  result = foldl(foldl(concat(rows),
                       $a & $b, ""),
                 # and add each individual 0 or 1
                 parseInt($a) + parseInt($b),
                 0)

template with_neighbors(loc: Coord,
                        actions: untyped): untyped =
  let (i, j) = loc
  # now search onwards from this element and add to same group
  for d in dirs:
    let
      x = i + d[0]
      y = j + d[1]
      pos {.inject.} = (x, y)
    actions

proc add_neighbor(grid: Table[Coord, int],
                  contained: var Table[Coord, int],
                  loc: Coord,
                  c_group: int) =
  # use template with neighbors to inject block of code into for loop over
  # adjacent squares. This way we don't have to have the code of with_neighbors
  # in this and the next proc
  # use to check whether neighbor is active square and if so add
  # to contained, call this function recursively to add every valid neighbor of
  # each neighbor we find
  with_neighbors(loc):
    if pos notin contained and pos in grid and grid[pos] == 1:
      contained[pos] = c_group
      add_neighbor(grid, contained, pos, c_group)

proc check_neighbors(contained: var Table[Coord, int],
                     loc: Coord): int =
  # use with neighbors to inject code to check whether neighbor
  # already contained
  with_neighbors(loc):
  # now search onwards from this element and add to same group
    if pos in contained:
      result = contained[pos]

proc calc_num_regions(keystring: string): int =
  let
    kh_input = toSeq(0..255)
    # create sequence of suffixes, calc knot hash for each string
    rows = mapIt(toSeq(0..127),
                 # for each string map every character
                 foldl(mapIt(calc_knot_hash(kh_input, (keystring & "-" & $it)),
                             # parse it from hex to int, convert int to binary of 4 bits
                             toBin(parseHexInt($it), 4)),
                       $a & $b, ""))
  var grid = initTable[Coord, int]() #seq[Coord] = @[] 
  for i in 0..127:
    for j in 0..127:
      if rows[i][j] == '1':
        grid[(i, j)] = 1
      else:
        grid[(i, j)] = 0

  # now traverse the grid and check neighboring fields, if they are connected
  var contained = initTable[Coord, int]()
  #var groups: seq[HashSet[Coord]] = @[]
  var n_groups = 0
  for i in 0..127:
    for j in 0..127:
      var c_group = 0
      if grid[(i, j)] == 1 and (i, j) notin contained:
        # add element to contained table indiciating of which group it is part
        c_group = check_neighbors(contained, (i, j))
        if c_group != 0:
          contained[(i, j)] = c_group
        else:
          inc n_groups
          contained[(i, j)] = n_groups
          c_group = n_groups
      elif grid[(i, j)] == 1 and (i, j) in contained:
        c_group = contained[(i, j)]
      elif grid[(i, j)] == 0:
        continue
      add_neighbor(grid, contained, (i, j), c_group)

  result = toSeq(contained.values).foldl(if a > b: a else: b)

proc run_tests() =
  const keystring = "flqrgnkx"
  check: calc_used_squares(keystring) == 8108
  check: calc_num_regions(keystring) == 1242
  
proc run_input() =
  let t0 = epochTime()
  const keystring = "ljoxqyyw"
  let used_squares = calc_used_squares(keystring)
  let num_regions = calc_num_regions(keystring)

  echo "(Part 1): The total number of used squares is = ", used_squares
  echo "(Part 2): The total number of clusters is = ", num_regions
  echo "Solutions took $#" % $(epochTime() - t0)
  
proc main() =
  run_tests()
  echo "All tests passed successfully. Result is (probably) trustworthy."
  run_input()
  
when isMainModule:
  main()
