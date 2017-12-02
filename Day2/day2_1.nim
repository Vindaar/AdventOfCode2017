import sequtils
import strutils
import future
import unittest

proc calc_checksum[T](data: openArray[T]): int =
  # proc to calc the checksum, by working on each line individually
  # and adding up all differences

  # parse the input data
  var rows: seq[seq[int]] = newSeq[seq[int]](len(data))
  for i, row in data:
    rows[i] = row.split().map(parseInt)

  result = foldl(map(rows,
                     (row: seq[int]) -> int => max(row) - min(row)),
                 a + b)

proc run_tests() =
  const data1_1 = split("""5 1 9 5
7 5 3
2 4 6 8""", "\n")
  check: calc_checksum(data1_1) == 18
  
proc run_input() =
  # read input at compile time
  const datfile = "input.txt"
  const data = split(strip(slurp(datfile)), "\n")
  echo "The resulting checksum is = ", calc_checksum(data)
  
proc main() =
  run_tests()
  echo "All tests successfully passed. Result is (probably) trustworthy."
  run_input()

when isMainModule:
  main()
