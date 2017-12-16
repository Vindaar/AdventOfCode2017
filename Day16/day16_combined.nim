import sequtils, strutils, unittest, times, typetraits, tables, sets

proc parse_dance_moves(instr, progs: seq[string]): seq[tuple[c: char, n1, n2: int]] =
  # proc to parse the dance moves 
  result = newSeq[tuple[c: char, n1, n2: int]](len(instr))
  let chars = zip(progs, toSeq(0..<16)).toTable
  for i, d in instr:
    case d[0]
    of 's':
      let n = parseInt(d.strip(chars = {'s'}))
      result[i] = ('s', n, 0)
    of 'x':
      let
        ns = d[1..d.high].split('/')
        n1 = parseInt(ns[0])
        n2 = parseInt(ns[1])
      result[i] = ('x', n1, n2)
    of 'p':
      let
        ps = d[1..d.high].split('/')
      result[i] = ('p', chars[ps[0]], chars[ps[1]]) 
    else:
      discard

template perform_dance(moves: typed, mprogs: typed) =
  for m in moves:
    case m[0]
    of 's':
      mprogs = concat(mprogs[^m[1]..^1], mprogs[0..^(m[1] + 1)])
    of 'x':
      swap(mprogs[m[1]], mprogs[m[2]])
    of 'p':
      let 
        p1 = chars[m[1]]
        p2 = chars[m[2]]
        n1 = mprogs.find(p1)
        n2 = mprogs.find(p2)
      swap(mprogs[n1], mprogs[n2])
    else:
      discard
      
proc let_progs_dance(moves: seq[tuple[c: char, n1, n2: int]], progs: seq[string], part2 = false): string =
  var
    mprogs = progs
    rounds = 0
    hashes: OrderedSet[string] = initOrderedSet[string]()
    hash = ""
    i = 0
    loop = false
    loop_period = 0
  let chars = zip(toSeq(0..<16), progs).toTable
  if part2 == false:
    rounds = 1
  else:
    rounds = 1_000_000_000

  hash = foldl(mprogs, $a & $b)
  hashes.incl(hash)
  while i < rounds:
    if loop == true:
      let d = rounds div loop_period
      i = loop_period * d
      loop = false
      
    perform_dance(moves, mprogs)
    inc i
    hash = foldl(mprogs, $a & $b)
    if loop_period == 0 and contains(hashes, hash) == false:
      hashes.incl(hash)
    elif loop_period == 0:
      loop_period = i
      loop = true

  result = foldl(mprogs, $a & $b)

proc run_tests() =
  const test_input = """s1,x3/4,pe/b"""
  const dance_instr = test_input.strip.split(',')
  let progs = mapIt({'a'..'e'}, $it)
  let moves = parse_dance_moves(dance_instr, progs)
  check: let_progs_dance(moves, progs) == "baedc"
  
proc run_input() =

  let t0 = epochTime()
  const input = "input.txt"
  const dance_instr = slurp(input).strip.split(',')
  let progs = mapIt({'a'..'p'}, $it)
  let moves = parse_dance_moves(dance_instr, progs)  
  let dance_result = let_progs_dance(moves, progs)
  let dance_alot = let_progs_dance(moves, progs, true)  
  
  echo "(Part 1): The location of the programs after dancing is = ", dance_result
  echo "(Part 2): The location of the programs after dancing 1e9 rounds is = ", dance_alot
  echo "Solutions took $#" % $(epochTime() - t0)
  
proc main() =
  run_tests()
  echo "All tests passed successfully. Result is (probably) trustworthy."
  run_input()
  
when isMainModule:
  main()
