import sequtils, future, times, unittest, strutils, threadpool

template with_get_vals(mgen: uint64, calcs: int, actions: untyped): untyped =
  for i in 0..<calcs:
    actions

proc get_next_genval(mgen, gen_mult, mod_w, uint64, calcs: int): uint64 {.inline.} =
  with_get_vals:
    result = uint64((mgen * gen_mult) mod mod_w)

proc get_genvals(mgen, gen_mult, mod_w, is_mod: uint64, calcs: int): seq[uint64] =
  result = @[]
  var gen_res = mgen
  with_get_vals:
    gen_res = (gen_res * gen_mult) mod mod_w
    while gen_res mod is_mod != 0:
      gen_res = (gen_res * gen_mult) mod mod_w
    result.add(gen_res)

proc judge_genvals_match(genA, genB: uint64, part2 = false): int =
  const
    genA_mult = 16807'u32
    genB_mult = 48271'u32
    is_modA   = 4'u32
    is_modB   = 8'u32
    # that's max(int32) isn't it? 0111...1
    mod_w = 2147483647'u32

  var calcs = 0
  if part2 == false:
    calcs = 40_000_000
  else:
    calcs = 5_000_000
  result = 0
  var
    mgenA: uint64 = genA
    mgenB: uint64 = genB

  if part2 == true:
    let
      mgenA_seq_f = spawn get_genvals(mgenA, genA_mult, mod_w, is_modA, calcs)
      mgenB_seq_f = spawn get_genvals(mgenB, genB_mult, mod_w, is_modB, calcs)
      mgenA_seq = ^mgenA_seq_f
      mgenB_seq = ^mgenB_seq_f
    #sync()
    for i in 0..<calcs:
      if i mod 1_000_000 == 0:
        echo "(Part 2): $# judge checks done" % $i
        echo mgenA, " ", mgenB
        
      mgenA = mgenA_seq[i]
      mgenB = mgenB_seq[i]
      if uint16((not (mgenA xor mgenB))) == 0xFFFF:
        inc result
  else:
    for i in 0..<calcs:
      if i mod 100_000_0 == 0:
        echo "(Part 1): $# judge iterations done" % $i
      #if part2 == false:
      mgenA = (mgenA * genA_mult) mod mod_w
      mgenB = (mgenB * genB_mult) mod mod_w
      if (not (uint16(mgenA) xor uint16(mgenB))) == 0xFFFF:
        inc result
    

proc run_tests() =
  const genA = 65'u32
  const genB = 8921'u32
  check: judge_genvals_match(genA, genB) == 588
  check: judge_genvals_match(genA, genB, true) == 309
  
proc run_input() =
  let t0 = epochTime()
  const genA = 512'u32
  const genB = 191'u32
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
