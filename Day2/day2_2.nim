import sequtils
import strutils
import future
import unittest
import zero_functional

proc calc_sum_divide[T](data: openArray[T]): int =
  # proc to calc the sum of evenly divisible numbers in each line

  # iterate over lines and, do ugly parsing
  var rows: seq[seq[int]] = newSeq[seq[int]](len(data))
  for i, row in data:
    var r: seq[int] = @[]
    let els = row.split()
    for el in els:
      r.add(parseInt(el))
    rows[i] = r

  let nums = foldl(mapIt(rows,
                         foldl(filterIt(map(it,
                                    (num: int) -> seq[int] => filterIt(it,
                                                                       num mod it == 0)),
                                  len(it) > 1)[0],
                         if a div b > 0: a div b else: b div a)),
                   a + b)

  # classic version:
  #[
  var val: int = 0  
  for row in rows:
    var value: int = 0
    for s in row:
      for t in row:
        value = if s mod t == 0: s div t else: 0
        if value > 1:
          break
      if value > 1:
        break
    val += value
  ]#
    
  echo "The resulting checksum is = ", nums
  result = nums

proc run_tests() =
  const data1_1 = split("""5 9 2 8
9 4 7 3
3 8 6 5""", "\n")
  check: calc_sum_divide(data1_1) == 9
  
proc run_input() =
  # read input at compile time
  const datfile = "input.txt"
  const data = split(strip(slurp(datfile)), "\n")
  discard calc_sum_divide(data)
  
proc main() =
  run_tests()
  echo "All tests successfully passed. Result is (probably) trustworthy."
  run_input()

when isMainModule:
  main()
