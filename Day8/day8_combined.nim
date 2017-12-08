import strutils, sequtils, future, algorithm, times, tables, unittest, macros

proc condition(a: int, op: string, b: int): bool =
  case op
  of ">": result = a > b
  of "<": result = a < b
  of ">=": result = a >= b
  of "<=": result = a <= b
  of "==": result = a == b
  of "!=": result = a != b

proc calc_max_register(registers: seq[string]): (int, int) =
  var reg_tab = initTable[string, int]()
  var max_val = 0
  for reg in registers:
    let ops = reg.split()
    if ops[4] notin reg_tab:
      reg_tab[ops[4]] = 0
    if ops[0] notin reg_tab:
      reg_tab[ops[0]] = 0
    if condition(reg_tab[ops[4]], ops[5], parseInt(ops[6])):
      if ops[1] == "inc":
        inc reg_tab[ops[0]], parseInt(ops[2])
      elif ops[1] == "dec":
        dec reg_tab[ops[0]], parseInt(ops[2])
    if reg_tab[ops[0]] > max_val:
      max_val = reg_tab[ops[0]]

  result = (max(toSeq(values(reg_tab))), max_val)

template run_tests() =
  const data = """b inc 5 if a > 1
a inc 1 if b < 5
c dec -10 if a >= 1
c inc -20 if c == 10"""
  const registers = splitLines(data)
  check: calc_max_register(registers) == (1, 10)
  
proc run_input() =

  let t0 = cpuTime()      
  const input = "input.txt"
  let registers = filterIt(splitLines(readFile(input)), len(it) > 0)
  let (max_reg, max_val) = calc_max_register(registers)
    
  echo "(Part 1): The value of the highest register is = ", max_reg
  echo "(Part 2): The highest register ever was = ", max_val
  echo "Solutions took $#" % $(cpuTime() - t0)
  
proc main() =
  run_tests()
  echo "All tests passed successfully. Result is (probably) trustworthy."
  run_input()

when isMainModule:
  main()


