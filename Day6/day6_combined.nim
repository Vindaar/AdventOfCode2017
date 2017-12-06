import sequtils, strutils, sets, os, unittest, times

proc calc_mem_redist(data: seq[int], part2 = false): (int, int) =
  # create mutable copy
  var mem = data
  # get length of input
  let length = len(mem)

  var
    # a hashset to store strings of memory layouts for comparison, ordered to
    # recover period of loop
    hashes: OrderedSet[string] = initOrderedSet[string]()
    # counter for part 1 until duplicate entry
    count = 0
    # string representation of current string to add to hashset
    mem_str: string = ""
    
  while true:
    inc count
    # get max value of memory 
    let max_val = max(mem)
    # and find corresopnding index
    var ind = find(mem, max_val)
    # set this element to 0 
    mem[ind] = 0

    for j in 0..<max_val:
      # redistribute values by adding 1 to each element following
      # previous max until all is redistributed. Take mod of length to
      # loop over whole seq
      ind = (ind + 1) mod length
      mem[ind] += 1

    # create string for current memory layout
    mem_str = foldl(mem, ($a & " ") & $b, "")
    # check if string already exists, indicates loop
    if contains(hashes, mem_str) == false:
      hashes.incl(mem_str)
    else:
      # found our loop
      break

  # now determine period of loop by extracting the index of the start of the loop
  # from the hash set (convert it to sequence and use find) and subtracting this
  # from the length of the hash set
  let count_since = len(hashes) - find(toSeq(items(hashes)), mem_str)
  result = (count, count_since)

proc run_tests() =
  const memory = "2 4 1 2"
  var ls: seq[int] = mapIt(filterIt(mapIt(split(strip(memory), " "), $it), len(it) > 0), parseInt($it))
  check: calc_mem_redist(ls) == (5, 4)

proc run_input() =

  let t0 = cpuTime()      
  const input = "input.txt"
  const memory = slurp(input)
  var ls: seq[int] = mapIt(split(strip(memory), " "), parseInt($it))
  
  let (p1, p2) = calc_mem_redist(ls)
  echo "(Part 1): Number of possible redistributions until loop = ", p1
  echo "(Part 2): Period of loop = ", p2
  let t1 = cpuTime()

  echo "Solutions took $#" % $(t1 - t0)
  
proc main() =
  run_tests()
  echo "All tests passed successfully. Result is (probably) trustworthy."
  run_input()

when isMainModule:
  main()
      
    
