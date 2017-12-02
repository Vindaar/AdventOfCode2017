import sequtils
import strutils
import future
import unittest

proc parse_data[T](data: openArray[T]): seq[seq[int]] =
  # parse the input data
  result = newSeq[seq[int]](len(data))
  for i, row in data:
    result[i] = row.split().map(parseInt)

proc calc_checksum(data: seq[seq[int]]): int =
  # proc to calc the checksum, by working on each line individually
  # and adding up all differences
  result = foldl(map(data,
                    (row: seq[int]) -> int => max(row) - min(row)),
                 a + b)

proc calc_sum_divide(data: seq[seq[int]]): int =
  # proc to calc the sum of evenly divisible numbers in each line
  # no clue why, but we get a SIGSEV if data is not mutable 
  var rows = data
  result = foldl(mapIt(rows,
                       foldl(filterIt(map(it,
                                      (num: int) -> seq[int] => filterIt(it,
                                                                         num mod it == 0)),
                                      len(it) > 1)[0],
                             if a div b > 0: a div b else: b div a)),
                 a + b)
  
proc run_tests() =
  const data1_1 = split("""5 1 9 5
7 5 3
2 4 6 8""", "\n")
  const data1_2 = split("""5 9 2 8
9 4 7 3
3 8 6 5""", "\n")
  check: calc_checksum(parse_data(data1_1)) == 18
  check: calc_sum_divide(parse_data(data1_2)) == 9
  
proc run_input() =
  # read input at compile time
  const datfile = "input.txt"
  const data = parse_data(split(strip(slurp(datfile)), "\n"))
  echo "The resulting checksum is = ", calc_checksum(data)
  echo "The resulting sum is = ", calc_sum_divide(data)
  
proc main() =
  run_tests()
  echo "All tests successfully passed. Result is (probably) trustworthy."
  run_input()

when isMainModule:
  main()
