import sequtils, strutils, algorithm, future, times, sets, unittest

proc follow_group(progs: seq[string], ind: int, visited_im: HashSet[int]): HashSet[int] =
  # from a starting group e.g. 0 check recursively each connected program, add program to seen
  # programs and call its first connected program. this way eventually cover all programs
  # to create a group
  let
    prog_str = progs[ind].split("<->")
    # current program we look at
    current = parseInt(strip(prog_str[0]))
    related = prog_str[1]
    # set of connected programs
    local_set = toSet(mapIt(split(related, ","), parseInt(strip(it))))
  # mutable copy of visited programs
  var visited = visited_im
  result = initSet[int]()
  # add current to the group
  result.incl(current)
  # check each connected, add to visited and recursively call 
  # this function for connected progs
  for p in local_set:
    if p notin visited:
      visited.incl(p)
      result = result + follow_group(progs, p, visited)

proc new_start(tot: int, in_groups: HashSet[int]): int =
  # procedure to get the new starting program for the next recursive call to follow_group
  # we check for all elements from 0 to number of programs in input, whether they are already
  # part of the checked groups
  var starts = toSeq(0..<tot)
  result = min(filterIt(starts, it notin in_groups))
  
proc calc_group_members(data: string): (int, int) =
  let progs = splitLines(strip(data))
  var
    group_sets: seq[HashSet[int]] = @[]
    in_groups: HashSet[int] = initSet[int]()

  while card(in_groups) < len(progs):
    let
      # determine new program to start from (based on already checked progs)
      start = new_start(len(progs), in_groups)
      # get the group of the current starting program
      group_set = follow_group(progs, start, toSet([0]))
    # add to seq of group sets
    group_sets.add(group_set)
    # and total programs in any group
    in_groups = in_groups + group_set
  
  return (card(group_sets[0]), len(group_sets))

proc run_tests() =
  const m1 = """0 <-> 2
1 <-> 1
2 <-> 0, 3, 4
3 <-> 2, 4
4 <-> 2, 3, 6
5 <-> 6
6 <-> 4, 5"""
  check: calc_group_members(m1) == (6, 2)
  
proc run_input() =

  let t0 = cpuTime()      
  const input = "input.txt"
  const comm_pipes = slurp(input)
  let (n_group0, n_groups) = calc_group_members(comm_pipes)

  echo "(Part 1): The number of elements in group of program 0 is = ", n_group0
  echo "(Part 2): The total number of groups is = ", n_groups
  echo "Solutions took $#" % $(cpuTime() - t0)
  
proc main() =
  run_tests()
  echo "All tests passed successfully. Result is (probably) trustworthy."
  run_input()
  
when isMainModule:
  main()
