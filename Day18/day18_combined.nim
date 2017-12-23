import sequtils, strutils, unittest, times, sets, typetraits, tables, os, threadpool

var
  chan0: Channel[int]
  chan1: Channel[int]
open(chan0)
open(chan1)

template setup_vars() {.dirty.} =
  # dirty template to simply setup the needed variables for the procs in
  # part 1 and part 2. reduce boilder plate
  let
    n_instr = len(input)
    regs = filterIt(mapIt(input, split(it)[1]), it[0] in {'a'..'z'}).toSet()
  var
    i = 0
    reg_tab = initTable[string, int]()
  for r in regs:
    reg_tab.add(r, 0)

proc run_prog_snd_rcv(input: seq[string], id: int): int =
  # almost exactly the same code as above, but this time run in parallel
  # id is the id of the program
  setup_vars()
  var
    # part 2 specific vars
    deadlocked = false
    count_snd = 0
  reg_tab["p"] = id
    
  while i >= 0 and i < n_instr:
    let
      instr = input[i].split()
      r = instr[1]
      rv = if r in regs: reg_tab[r] else: parseInt(r)
    var s: int 
    if len(instr) > 2:
      s = if instr[2] in regs: reg_tab[instr[2]] else: parseInt(instr[2])
    case instr[0]
    of "snd":
      # in this case put current value into other queue
      if id == 0:
        chan0.send(rv)
      else:
        chan1.send(rv)
      inc count_snd
    of "set":
      reg_tab[r] = s
    of "add":
      reg_tab[r] += s
    of "mul":
      reg_tab[r] *= s
    of "mod":
      reg_tab[r] = rv mod s
    of "rcv":
      var t = 0
      while true:
        var
          is_data = false
          data = -1
        if id == 0:
          (is_data, data) = chan1.tryRecv()
        else:
          (is_data, data) = chan0.tryRecv()
        if is_data == true:
          reg_tab[r] = data
          break
        else:
          # without a short sleep here, we just end up in an endless loop
          sleep(5)
        inc t
        if t > 10:
          # instead of breaking from the 2 while loops, simply return the
          # current counter from here
          return count_snd
    of "jgz":
      if rv > 0:
        i += s
        continue
    else:
      discard
    inc i

  # this will never be reached, since we should return from within the
  # 'rcv' while loop
  result = count_snd
  

proc snd_rcv_channels(input: seq[string]): int =
  let
    snd0 = spawn run_prog_snd_rcv(input, 0)
    snd1 = spawn run_prog_snd_rcv(input, 1)
  sync()
  # return counter of program 1
  result = ^snd1

proc play_song_get_freq(input: seq[string]): int =
  setup_vars()
  var f_played: int
    
  while i >= 0 and i < n_instr:
    let
      instr = input[i].split()
      r = instr[1]
      rv = if r in regs: reg_tab[r] else: parseInt(r)
    var s: int 
    if len(instr) > 2:
      s = if instr[2] in regs: reg_tab[instr[2]] else: parseInt(instr[2])
    case instr[0]
    of "snd":
      f_played = rv
    of "set":
      reg_tab[r] = s
    of "add":
      reg_tab[r] += s
    of "mul":
      reg_tab[r] *= s
    of "mod":
      reg_tab[r] = rv mod s
    of "rcv":
      if rv != 0:
        break
    of "jgz":
      if rv > 0:
        i += s
        continue
    else:
      discard
    inc i

  result = f_played


proc run_tests() =
  const input1 = """
set a 1
add a 2
mul a a
mod a 5
snd a
set a 0
rcv a
jgz a -1
set a 1
jgz a -2
"""
  const input2 = """
snd 1
snd 2
snd p
rcv a
rcv b
rcv c
rcv d
"""
  check: play_song_get_freq(input1.strip.splitLines) == 4
  check: snd_rcv_channels(input2.strip.splitLines) == 3

proc run_input() =
  let t0 = epochTime()
  const input = slurp("input.txt").strip.splitLines
  let first_played_freq = play_song_get_freq(input)
  let prog1_sends = snd_rcv_channels(input)  
  
  echo "(Part 1): The first non-zero played freq is = ", first_played_freq
  echo "(Part 2): Progam 1 sent this many times = ", prog1_sends
  echo "Solutions took $#" % $(epochTime() - t0)
  
proc main() =
  run_tests()
  echo "All tests passed successfully. Result is (probably) trustworthy."
  run_input()
  
when isMainModule:
  main()
