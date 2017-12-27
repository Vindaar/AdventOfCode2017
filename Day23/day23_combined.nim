import sequtils, strutils, unittest, times, sets, typetraits, tables, os

template setup_vars() {.dirty.} =
  # dirty template to simply setup the needed variables for the procs in
  # part 1 and part 2. reduce boilder plate
  let
    n_instr = len(input)
    regs = filterIt(mapIt(input, split(it)[1]), it[0] in {'a'..'h'}).toSet()
  var
    i = 0
    reg_tab = initTable[string, int]()
  for r in regs:
    reg_tab.add(r, 0)

proc num_mult_invoked(input: seq[string]): int =
  setup_vars()
  while i >= 0 and i < n_instr:
    let
      instr = input[i].split()
      r = instr[1]
      rv = if r in regs: reg_tab[r] else: parseInt(r)
    var s: int
    if len(instr) > 2:
      s = if instr[2] in regs: reg_tab[instr[2]] else: parseInt(instr[2])
    case instr[0]
    of "set":
      reg_tab[r] = s
    of "sub":
      reg_tab[r] -= s
    of "mul":
      reg_tab[r] *= s
      inc result
    of "jnz":
      if rv != 0:
        i += s
        continue
    else:
      discard
    inc i

proc run_input() =
  let t0 = epochTime()
  const input = slurp("input.txt").strip.splitLines
  let n_mul_invoked = num_mult_invoked(input)
  
  echo "(Part 1): Number coprocessor invoked 'mul' = ", n_mul_invoked
  echo "(Part 2): Part 2 done in separate file."
  echo "Solutions took $#" % $(epochTime() - t0)
  
proc main() =
  echo "No tests available"
  run_input()
  
when isMainModule:
  main()
