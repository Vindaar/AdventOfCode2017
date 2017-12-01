import sequtils
import strutils
import fp/list
import future
import unittest

proc `[]`*[T](a: seq[T], inds: openArray[int]): seq[T] {.inline.} =
  ## given two openArrays, return a sequence of all elements whose indices
  ## are given in 'inds'
  ## inputs:
  ##    a: seq[T] = the sequence from which we take values
  ##    inds: openArray[int] = the array which contains the indices for the
  ##         arrays, which we take from 'array'
  ## outputs:
  ##    seq[T] = a sequence of all elements s.t. array[ind] in numpy indexing
  result = map(inds, (ind: int) -> T => a[ind])

proc arange*(start, stop, step: int): seq[int] = 
  result = @[]
  for i in start..<stop:
    if (i - start) mod step == 0:
      result.add(i)

proc calculate_double_numbers_shifted[T](data: openArray[T]): int =
  # create sequence to store integers after conversion from strings
  var data_seq: seq[int] = @[]
  for d in data:
    data_seq.add(parseInt($d))

  # our second list now needs to be clyclicly rotated by half the elements
  # in it, calculate
  # define helper constants
  let
    num = data_seq.len
    # lower and upper index for rotated list (before taking mod), subtract one, because
    # one shift is already taken up by checking for later
    i_low = int(num / 2)
    i_up  = int(num * 3 / 2)
    # get a range of indices in range from above
    ind = arange(i_low, i_up, 1)
    # create seq of indices to use, by taking mod with number of elements
    # s.t. every index larger than num takes from beginning of list
    indices = map(ind, (x: int) -> int => x mod num)
    # get the elements our original seq by using the list of indices
    data_seq_rot = data_seq[indices]

  # now create 2 lists, in this case no need to add last element from list, as we already
  # take that into account implicitly
  let data_lst2 = data_seq_rot.asList
  # the other stores a 0 (to pad it to the same length) and the sequence
  let data_lst1 = data_seq.asList

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
  const data1 = "1212"
  check: calculate_double_numbers_shifted(data1) == 6  

  const data2 = "1221"
  check: calculate_double_numbers_shifted(data2) == 0

  const data3 = "123425"
  check: calculate_double_numbers_shifted(data3) == 4

  const data4 = "123123"
  check: calculate_double_numbers_shifted(data4) == 12

  const data5 = "12131415"
  check: calculate_double_numbers_shifted(data5) == 4
  
proc run_input() =
  # read input at compile time
  const datfile = "input.txt"
  const data = strip(slurp(datfile))
  discard calculate_double_numbers_shifted(data)

proc main() =
  run_tests()
  echo "All tests successfully passed. Result is (probably) trustworthy."
  run_input()

when isMainModule:
  main()
