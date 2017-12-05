import sequtils, future, algorithm, strutils, unittest, times

proc calc_steps(data: seq[int], part2 = false): int =
  # given the maze as input data, calculate number of steps needed to get out
  var
    maze = data
    steps = 0
    jump_to = 0
    loc = 0
    
  while jump_to < len(maze) and jump_to >= 0:
    loc = jump_to
    jump_to = loc + maze[loc]
    if part2 == true:
      if maze[loc] >= 3:
        dec maze[loc]
      else:
        inc maze[loc]
    else:
      inc maze[loc]
    inc steps

  result = steps

proc calc_steps_recursive(maze: var seq[int], loc = 0, steps = 0, part2 = false): int = 
  # given the maze as input data, calculate number of steps needed to get out rescursively
  if loc >= len(maze) or loc < 0:
    result = steps
  else:
    let jump_to = loc + maze[loc]
    if part2 == true:
      if maze[loc] >= 3:
        dec maze[loc]
      else:
        inc maze[loc]
    else:
      inc maze[loc]
    result = calc_steps_recursive(maze, jump_to, steps + 1, part2)
  
proc run_tests() =
  const maze= """0
3
0
1
-3"""
  var lines = mapIt(splitLines(maze), parseInt(it))
  check: calc_steps(lines, false) == 5
  check: calc_steps(lines, true) == 10

  # make copy, since list will be altered on first call
  var lines2 = lines
  check: calc_steps_recursive(lines, part2 = false) == 5
  check: calc_steps_recursive(lines2, part2 = true) == 10


proc run_input() =
  const input = "input.txt"
  const maze = slurp(input)

  var lines = mapIt(filterIt(mapIt(splitLines(maze), it), len(it) > 0), parseInt(it))
  
  echo "(Part 1): Number of steps to get out of the maze is = ", calc_steps(lines, false)
  let t0 = cpuTime()
  echo "(Part 2): Number of steps to get out of the maze is = ", calc_steps(lines, true)
  let t1 = cpuTime()

  var lines2 = lines
  echo "(Part 1 recur): Number of steps to get out of the maze is = ", calc_steps_recursive(lines, part2 = false)
  let t2 = cpuTime()
  echo "(Part 2 recur): Number of steps to get out of the maze is = ", calc_steps_recursive(lines2, part2 = true)
  let t3 = cpuTime()

  echo "Solution using while took $#" % $(t1 - t0)
  echo "Solution using recursion took $#" % $(t3 - t2)  

  
proc main() =
  run_tests()
  echo "All tests passed successfully. Result is (probably) trustworthy."
  run_input()

when isMainModule:
  main()
