import sequtils, strutils, unittest, times, sets, typetraits, tables

const
  # down and up are reversed intuitively, because we start
  # at the top and go down, which means /increasing/ the index
  # for y
  DOWN  = (0, 1)
  UP    = (0, -1)
  RIGHT = (1, 0)
  LEFT  = (-1, 0)

proc run_packet_path(input: seq[string], part2 = false): string =
  result = ""
  let start = (0, input[0].find('|'))
  var move = DOWN
  var
    (y, x) = start
    steps = 0
  while true:
    # count the steps
    inc steps
    # perform a move
    x += move[0]
    y += move[1]
    let pos = input[y][x]
    # if pos is now an empty string, we've reached the end
    if ($pos).strip == "":
      break
    # now check this position
    case pos
    of '|', '-':
      # in this case continue to move in the same direction
      # which means just continue
      continue
    of '+':
      # now we need to turn. Need to check whats going on
      # in the direction orthogonal to our previous moving direction
      if move == UP or move == DOWN:     
        # check left and right
        let l = input[y + LEFT[1]][x + LEFT[0]]
        let r = input[y + RIGHT[1]][x + RIGHT[0]]
        if ($l).strip != "":
          # in this case something is found here, continue
          # that direction (assume only one is valid!)
          move = LEFT
          continue
        elif ($r).strip != "":
          move = RIGHT
          continue
      elif move == LEFT or move == RIGHT:
        # check up and down
        let u = input[y + UP[1]][x + UP[0]]
        let d = input[y + DOWN[1]][x + DOWN[0]]
        if ($u).strip != "":
          move = UP
          continue
        elif ($d).strip != "":
          move = DOWN
          continue
    else:
      # means we've found a letter, add to result
      result &= pos

  if part2 == true:
    result = $steps

proc run_tests() =
  const input = """
     |          
     |  +--+    
     A  |  C    
 F---|----E|--+ 
     |  |  |  D 
     +B-+  +--+ 
"""
  check: run_packet_path(input.splitLines) == "ABCDEF"
  check: run_packet_path(input.splitLines, true) == "38"

proc run_input() =
  let t0 = epochTime()
  const input = slurp("input.txt").splitLines
  let packet_path = run_packet_path(input)
  let step_count = run_packet_path(input, true)
  
  echo "(Part 1): The path the packet takes is = ", packet_path
  echo "(Part 2): The total number of steps to take = ", step_count
  echo "Solutions took $#" % $(epochTime() - t0)
  
proc main() =
  run_tests()
  echo "All tests passed successfully. Result is (probably) trustworthy."
  run_input()
  
when isMainModule:
  main()
