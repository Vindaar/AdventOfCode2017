import strutils, sequtils, future, algorithm, times, unittest, math

proc reverse[T](s: var seq[T], first, last: int) =
  # reverses the sequence or array in place from first to last.
  # if first is larger than last, we wrap around the end of the sequence
  # similar to algorithm.reverse, but allows wrapping around ending
  var
    x = first
    y = last
  if first == last:
    return
  elif first > len(s) or last > len(s):
    raise newException(IndexError, "`first` / `last` in reverse needs to be smaller than length of openArray")
  elif first > last:
    y = last + len(s)
  while x < y:
    let j = y mod len(s)
    let i = x mod len(s)
    swap(s[i], s[j])
    dec y
    inc x
    
proc calc_hash_round(s, input: seq[int], skip_size: var int, pos: var int): seq[int] =
  # calculate one hashing round, for part 1 only one round performed
  var last = 0
  result = s

  for l in input:
    # only calculate last position to revert, if l larger than 0, else we
    # run into trouble
    last = if l > 0: (pos + l - 1) mod len(result) else: pos
    # perform reversal of the given substring from pos to last (incl. wrapping)
    reverse(result, pos, last)
    # calculate new position in string
    pos = (pos + l + skip_size) mod len(result)
    inc skip_size
  
proc calc_knot_hash*(s: seq[int], input: string): string =
  var
    # mutable copy
    sparse_hash = s
    skip_size = 0
    pos = 0
    last = 0
    # convert ASCII to ints and concat the specific suffix 
    to_hash = concat(mapIt(input, int(it)), @[17, 31, 73, 47, 23])
  
  for i in 0..<64:
    # calc one hash round, note that skip_size and pos are handed by reference and
    # changed in the calc_hash_round function
    sparse_hash = calc_hash_round(sparse_hash, to_hash, skip_size, pos)
    
  # given the sparse hash, calculate `xor` of each 16 consecutive characters and convert to
  # hex representation
  let hexed = mapIt(distribute(sparse_hash, 16), toHex(foldl(it, a xor b)))
  # then cut off the beginning 0s (due to Nim's toHex fn) and convert all hex values
  # to single string
  let dense_hash = foldl(mapIt(hexed, it[^2..^1]), $a & $b)

  # output expects lower ascii for hex representation
  result = toLowerAscii($dense_hash)
  

proc run_tests() =
  var
    skip_size = 0
    pos = 0
  
  var str = toSeq(0..4)
  let s1 = mapIt(split("3,4,1,5", ','), parseInt(it))
  let hash_round = calc_hash_round(str, s1, skip_size, pos)
  check: (hash_round[0] * hash_round[1]) == 12

  const aoc = "AoC 2017"
  check: calc_knot_hash(toSeq(0..255), aoc) == "33efeb34ea91902bb2f59c9920caa6cd"
  const empty = ""
  check: calc_knot_hash(toSeq(0..255), empty) == "a2582a3a0e66e6e86e3812dcb672a272"
  const count = "1,2,3"
  check: calc_knot_hash(toSeq(0..255), count) == "3efbe78a8d82f29979031a4aa0b16a9d"


proc run_input() =
  var
    skip_size = 0
    pos = 0

  let t0 = cpuTime()      
  const input = "input.txt"
  let to_hash = strip(readFile(input))
  let to_reverse = mapIt(split(to_hash, ','), parseInt(it))
  let product = calc_hash_round(toSeq(0..255), to_reverse, skip_size, pos)
  let hash = calc_knot_hash(toSeq(0..255), to_hash)
    
  echo "(Part 1): The product of the hashed string is = ", $(product[0] * product[1])
  echo "(Part 2): The knot hash of the input is = ", hash
  echo "Solutions took $#" % $(cpuTime() - t0)
  
proc main() =
  run_tests()
  echo "All tests passed successfully. Result is (probably) trustworthy."
  run_input()
  
when isMainModule:
  main()



