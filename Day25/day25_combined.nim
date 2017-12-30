import sequtils, strutils, algorithm, unittest, times, sets, typetraits, tables

type
  Move = enum
    LEFT  = -1,
    NONE  = 0
    RIGHT = 1

type
  Instr = object
    state: char
    zero_write: int
    zero_move: Move
    zero_state: char
    one_write: int
    one_move: Move
    one_state: char

proc parse_move(line: string): Move =
  let move = line.strip.split[^1].strip(chars = {'.'})
  if move == "left":
    result = LEFT
  elif move == "right":
    result = RIGHT

proc parse_write(line: string): char =
  result = strip(line)[^2]

proc parse_nextstate(line: string): char =
  result = strip(line)[^2]

proc parse_instructions(desc: seq[string]): (char, int, Table[char, Instr]) =
  # first parse the beginning state and number of steps to perform
  let begin_in = desc[0][^2]
  let steps = parseInt(desc[1].split()[^2])
  echo "We begin in state $# and perform $# steps" % [$begin_in, $steps]
  var
    instr_tab: Table[char, Instr] = initTable[char, Instr]()
    instr: Instr = Instr(zero_move: NONE, one_move: NONE)

  var statemachine = desc[3..desc.high]
  for i in 0..statemachine.high:
    let line = statemachine[i]
    if line == "":
      # one state done
      instr_tab[instr.state] = instr
      instr = Instr(zero_move: NONE, one_move: NONE)
    else:
      if i mod 10 == 0:
        let s = strip(line)[^2]
        instr.state = s
      elif i mod 10 == 1:
        # marks beginning of zero_
        discard
      elif i mod 10 == 2:
        instr.zero_write = parseInt($parse_write(line))
      elif i mod 10 == 3:
        instr.zero_move = parse_move(line)
      elif i mod 10 == 4:
        instr.zero_state = parse_nextstate(line)
      elif i mod 10 == 6:
        instr.one_write = parseInt($parse_write(line))
      elif i mod 10 == 7:
        instr.one_move = parse_move(line)
      elif i mod 10 == 8:
        instr.one_state = parse_nextstate(line)
  # finally add last instruction
  instr_tab[instr.state] = instr
  result = (begin_in, steps, instr_tab)
  
    
proc check_turing_machine(desc: seq[string]): int =
  let (begin_in, steps, instr_tab) = parse_instructions(desc)
  var
    tape = initTable[int, int]()
    state: char = begin_in
    move: Move = None
    loc = 0
    val = 0
    write_val = 0
    instr: Instr = Instr(zero_move: NONE, one_move: NONE)
  for i in 0..<steps:
    instr = instr_tab[state]
    if hasKey(tape, loc) == false:
      tape[loc] = 0
    val = tape[loc]
    if val == 0:
      move = instr.zero_move
      write_val = instr.zero_write
      state = instr.zero_state
    elif val == 1:
      move = instr.one_move
      write_val = instr.one_write
      state = instr.one_state
    tape[loc] = write_val
    loc += int(move)

  result = foldl(toSeq(tape.values), a + b)
  
proc run_tests() =
  const input1 = """
Begin in state A.
Perform a diagnostic checksum after 6 steps.

In state A:
  If the current value is 0:
    - Write the value 1.
    - Move one slot to the right.
    - Continue with state B.
  If the current value is 1:
    - Write the value 0.
    - Move one slot to the left.
    - Continue with state B.

In state B:
  If the current value is 0:
    - Write the value 1.
    - Move one slot to the left.
    - Continue with state A.
  If the current value is 1:
    - Write the value 1.
    - Move one slot to the right.
    - Continue with state A.
"""
  check: check_turing_machine(input1.strip.splitLines) == 3
  
proc run_input() =
  let t0 = epochTime()
  const input = slurp("input.txt").strip.splitLines
  let checksum = check_turing_machine(input)
    
  echo "(Part 1): The diagnostic checksum of the turing machine is ", checksum
  echo "(Part 2): ?"
  echo "Solutions took $#" % $(epochTime() - t0)
  
proc main() =
  run_tests()
  echo "All tests passed successfully. Result is (probably) trustworthy."
  run_input()
  
when isMainModule:
  main()
