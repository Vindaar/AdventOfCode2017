import strutils, math, tables, future

type
  Coord = tuple[x, y: int]

proc find[U, V](tab: Table[U, V], val: V): U =
  for k, v in tab:
    if v == val:
      result = k
      break

proc max[U, V](tab: Table[U, V]): V =
  result = 0
  for v in values(tab):
    if v > result:
      result = v

proc calcDist(tab: Table[Coord, int], val: int): int =
  # calculates the disctance to the center for a value given by val
  let coord = tab.find(val)
  result = abs(coord.x) + abs(coord.y)

proc calcValue(tab: Table[Coord, int], c: Coord): int =
  # given a coordinate, calculate the value of that element
  var
    x = 0
    y = 0
  const moves = [ (1, 0), (1, 1), (0, 1), (-1, 1), (-1, 0), (-1, -1), (0, -1), (1, -1) ]
  for i in 0..<8:
    let (move_x, move_y) = moves[i]
    x = c.x + move_x
    y = c.y + move_y
    if tab.hasKey((x, y)) == true:
      result += tab[(x, y)]

proc createTable(val: int, part2 = false): Table[Coord, int] =
  # creates table up to point val
  result = initTable[Coord, int]()
  var
    v = 1
    count_x = 0
    count_y = 0
    move: tuple[x: int, y: int] = (1, 0)
    count = 0
    count_to = 1
  # set access point (0 / 0)
  result[(0, 0)] = v
  while v <= val:
    count_x += move.x
    count_y += move.y
    # increase count and value of element
    if part2 == true:
      v = calcValue(result, (count_x, count_y))
    else:
      inc v
    inc count
    result[(count_x, count_y)] = v
    if count == count_to:
      # change the direction of movement
      if move == (1, 0):
        move = (0, 1)
      elif move == (0, 1):
        move = (-1, 0)
        inc count_to
      elif move == (-1, 0):
        move = (0, -1)
      elif move == (0, -1):
        move = (1, 0)
        inc count_to
      # reset move counter
      count = 0

proc calc_steps(x: int): int =
  let tab = create_table(x)
  result = calcDist(tab, x)
  echo "Result is $# for value of $#" % [$result, $x]

proc calc_max(x: int): int =
  let tab = create_table(x, true)
  result = max(tab)
  echo "Result is $# for value of $#" % [$result, $x]
  
when isMainModule:
  const input = parseInt("277678")
  discard calc_max(input)
  discard calc_steps(input)



proc calcEdge(ring: int): int =
  # given a ring calculate the lenght of the edges
  result = 1
  for i in 0..<ring:
    result += 2

proc calcRing(x: int): int =
  # returns the ring on which x lies
  var
    count = 1
    edge = 1
  result = 0
  while count < x:
    edge += 2
    count += 2 * edge + 2 * (edge - 2)
    inc result

proc calc_steps_old(x: int): int =
  let
    a = calcRing(x)
    edge = calcEdge(a)
    count = (edge - 2) * (edge - 2)
    diff = x - count
  var full: int
  if edge > 1:
    if diff - edge > 0:
      full = 1 + (diff - edge) div (edge - 1)
  else:
    full = 0
  let rest = diff - full * (edge - 1)
  result = a + abs(rest - (edge) div 2)
  
