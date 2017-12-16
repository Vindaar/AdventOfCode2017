import sequtils, future, times, unittest, strutils, threadpool

# after failing to find a solution using multiprocessing, which is actually faster
# (and not slower :( ), I guess I'll go with the boring solution...

proc next_p2(mgen, gen_mult, mod_w, is_mod: int): int {.inline.} =
  result = (mgen * gen_mult) mod mod_w
  while result mod is_mod != 0:
    result = (result * gen_mult) mod mod_w

proc judge_genvals_match(genA, genB: int, part2 = false): int =
  const
    genA_mult = 16807
    genB_mult = 48271
    is_modA   = 4
    is_modB   = 8
    # that's max(int32) -1 isn't it?
    mod_w = 2147483647
  var
    calcs = 0
    mgenA = genA
    mgenB = genB
    
  if part2 == false:
    calcs = 40_000_000    
    for i in 0..<calcs:
      mgenA = (mgenA * genA_mult) mod mod_w
      mgenB = (mgenB * genB_mult) mod mod_w      
      if (mgenA and 0xFFFF) == (mgenB and 0xFFFF):
        inc result
  else:
    calcs = 5_000_000
    for i in 0..<calcs:
      mgenA = next_p2(mgenA, genA_mult, mod_w, is_modA)
      mgenB = next_p2(mgenB, genB_mult, mod_w, is_modB)      
      if (mgenA and 0xFFFF) == (mgenB and 0xFFFF):        
        inc result      
      
proc run_tests() =
  const genA = 65
  const genB = 8921
  check: judge_genvals_match(genA, genB) == 588
  check: judge_genvals_match(genA, genB, true) == 309
  
proc run_input() =
  let t0 = epochTime()
  const genA = 512
  const genB = 191
  let num = judge_genvals_match(genA, genB)
  let num_picky = judge_genvals_match(genA, genB, true)
  
  echo "(Part 1): The number the generators match on last 16 bits = ", num
  echo "(Part 2): The number of picky iterator matches on last 16 bits = ", num_picky
  echo "Solutions took $#" % $(epochTime() - t0)
  
proc main() =
  run_tests()
  echo "All tests passed successfully. Result is (probably) trustworthy."
  run_input()
  
when isMainModule:
  main()
