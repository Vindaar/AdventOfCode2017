import sequtils
import strutils
import fp/list
import future

proc calculate_double_numbers[T](data: openArray[T]): int =
  # create sequence to store integers after conversion from strings
  var data_seq: seq[int] = @[]
  for d in data:
    data_seq.add(parseInt($d))

  # now create 2 lists, one stores the sequence + the first element
  let data_lst2 = data_seq.asList ++ data_seq[0].asList
  # the other stores a 0 (to pad it to the same length) and the sequence
  let data_lst1 = 0 ^^ data_seq.asList

  # now calculate desired number by zipping two lists
  result = foldLeft(map(zip(data_lst1, data_lst2),
                        # mapping all elements, which are the same in both lists (as they are
                        # shifted by 1 this is what we want)
                        (t: tuple[a, b: int]) -> int => (if t.a == t.b: t.a else: 0)),
                    # now use fold to sum the list
                    0,
                    (x, y) => x + y)

  echo "The result is = ", result


proc run_tests() =   
  const data1 = "1122"
  assert calculate_double_numbers(data1) == 3

  const data2 = "1111"
  assert calculate_double_numbers(data2) == 4

  const data3 = "1234"
  assert calculate_double_numbers(data3) == 0

  const data4 = "91212129"
  assert calculate_double_numbers(data4) == 9
  
proc run_input() =
  # read input at compile time
  const datfile = "input.txt"
  const data = strip(slurp(datfile))
  discard calculate_double_numbers(data)

proc main() =
  run_tests()
  echo "All tests successfully passed. Result is (probably) trustworthy."
  run_input()

when isMainModule:
  main()
