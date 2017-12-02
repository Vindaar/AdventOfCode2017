import sequtils
import strutils
import future
import unittest

proc calc_checksum[T](data: openArray[T]): int =
  # proc to calc the checksum, by working on each line individually
  # and adding up all differences

  # iterate over lines and, do ugly parsing
  var rows: seq[seq[int]] = newSeq[seq[int]](len(data))
  for i, row in data:
    var r: seq[int] = @[]
    let els = row.split()
    for el in els:
      r.add(parseInt(el))
    rows[i] = r

  result = foldl(map(rows,
                     (row: seq[int]) -> int => max(row) - min(row)),
                 a + b)

  echo "The resulting checksum is = ", result

proc run_tests() =
  const data1_1 = split("""5 1 9 5
7 5 3
2 4 6 8""", "\n")
  check: calc_checksum(data1_1) == 18
  
proc run_input() =
  # read input at compile time
  const datfile = "input.txt"
  const data = split(strip(slurp(datfile)), "\n")
  discard calc_checksum(data)
  
proc main() =
  run_tests()
  echo "All tests successfully passed. Result is (probably) trustworthy."
  run_input()

when isMainModule:
  main()
