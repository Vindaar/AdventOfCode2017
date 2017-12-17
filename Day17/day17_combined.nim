import sequtils, strutils, unittest, times, future

proc calc_spinlock_stop_p2(jumps, insertions: int): int =
  var
    ind = 1

  result = max(filterIt(toSeq(1..insertions)) do:
    # filter out all values, which would be inserted at position one
    let insert_at = (ind + jumps) mod it + 1
    ind = insert_at
    insert_at == 1)

proc calc_spinlock_stop_p1(jumps: int): int =
  var
    buffer: seq[int] = @[0]
    ind = 0

  for i in 1..2017:
    let insert_at = (ind + jumps) mod len(buffer) + 1
    buffer.insert(i, insert_at)
    ind = insert_at

  result = buffer[(ind + 1) mod len(buffer)]

proc run_tests() =
  const jumps = 3
  check: calc_spinlock_stop_p1(jumps) == 638

proc run_input() =
  let t0 = epochTime()
  const jumps = 382
  let spinlock_stop = calc_spinlock_stop_p1(jumps)
  let spinlock_angry = calc_spinlock_stop_p2(jumps, 50_000_000)
  
  echo "(Part 1): The value in the register behind the spinlock's stop = ", spinlock_stop
  echo "(Part 2): The value after 0 after 50.000.000 insertions is =  ", spinlock_angry
  echo "Solutions took $#" % $(epochTime() - t0)
  
proc main() =
  run_tests()
  echo "All tests passed successfully. Result is (probably) trustworthy."
  run_input()
  
when isMainModule:
  main()
