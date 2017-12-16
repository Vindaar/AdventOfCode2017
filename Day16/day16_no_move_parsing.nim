import sequtils, strutils, unittest, times, typetraits, sets

template perform_dance(moves: typed, mprogs: typed) =
  for m in moves:
    case m[0]
    of 's':
      let n = parseInt(m.strip(chars = {'s'}))
      mprogs = concat(mprogs[^n..^1], mprogs[0..^(n + 1)])
    of 'x':
      let 
        ns = m[1..m.high].split('/')
        n1 = parseInt(ns[0])
        n2 = parseInt(ns[1])      
      swap(mprogs[n1], mprogs[n2])
    of 'p':
      let
        ps = m[1..m.high].split('/')
        n1 = mprogs.find(ps[0])
        n2 = mprogs.find(ps[1])
      swap(mprogs[n1], mprogs[n2])
    else:
      discard
      
proc let_progs_dance(moves, progs: seq[string], part2 = false): string =
  var
    mprogs = progs
    rounds = 0
    hash = ""
    hashes: OrderedSet[string] = initOrderedSet[string]()
    i = 0
    # loop controls whether we have found a loop
    loop = false
    # loop period stores the length of one period
    loop_period = 0
  if part2 == false:
    rounds = 1
  else:
    rounds = 1_000_000_000

  # add starting position to hash set
  hash = foldl(mprogs, $a & $b)
  hashes.incl(hash)
  while i < rounds:
    if loop == true:
      # calculate number of full loops in total number of rounds
      let d = rounds div loop_period
      # set i to last completed round and continue from there
      i = loop_period * d
      loop = false
    # perform a single full dance
    perform_dance(moves, mprogs)
    inc i
    # after increasing counter check if current hash in hashset
    hash = foldl(mprogs, $a & $b)
    if loop_period == 0 and contains(hashes, hash) == false:
      # if not add
      hashes.incl(hash)
    elif loop_period == 0:
      # else set current count value as loop period
      loop_period = i
      loop = true

  result = foldl(mprogs, $a & $b)

proc run_tests() =
  const test_input = """s1,x3/4,pe/b"""
  const dance_instr = test_input.strip.split(',')
  let progs = mapIt({'a'..'e'}, $it)
  check: let_progs_dance(dance_instr, progs) == "baedc"
  
proc run_input() =

  let t0 = epochTime()
  const input = "input.txt"
  const dance_instr = slurp(input).strip.split(',')
  let progs = mapIt({'a'..'p'}, $it)
  let dance_result = let_progs_dance(dance_instr, progs)
  let dance_alot = let_progs_dance(dance_instr, progs, true)  
  
  echo "(Part 1): The location of the programs after dancing is = ", dance_result
  echo "(Part 2): The location of the programs after dancing 1e9 rounds is = ", dance_alot
  echo "Solutions took $#" % $(epochTime() - t0)
  
proc main() =
  run_tests()
  echo "All tests passed successfully. Result is (probably) trustworthy."
  run_input()
  
when isMainModule:
  main()
