import unittest, strutils, sequtils, future, sets, algorithm

proc hash_and_compare(words: seq[string]): bool = 
  let word_set = toSet(words)
  result = if len(words) != len(word_set): false else: true

proc check_password(pword: string, part2 = false): bool =
  # proc to check whether a given password is valid
  let words = mapIt(split(pword, " "), it)
  if part2 == false:
    result = hash_and_compare(words)
  else:
    let sorted_words = mapIt(words, foldl(sorted(it, system.cmp), a & b, ""))
    # given sorted words, can now check for different passwords in same
    # way as before. Create hashset of words, check for differences in length
    result = hash_and_compare(sorted_words)
  
proc check_lst_of_passwords(pwords: seq[string], part2 = false): int =
  # receives a list of passwords, checks each with check_password
  # and resturns an int of the number of valid passwords
  # define the regex to match the words in the password
  result = len(filterIt(pwords, check_password(it, part2)))

proc run_tests() =
  # part 1
  const test1 = "aa bb cc dd ee"
  check: check_password(test1) == true
  const test2 = "aa bb cc dd aa"
  check: check_password(test2) == false
  const test3 = "aa bb cc dd aaa"
  check: check_password(test3) == true
  # part 2
  const test4 = "abcde fghij"
  check: check_password(test4, true) == true
  const test5 = "abcde xyz ecdab"
  check: check_password(test5, true) == false
  const test6 = "a ab abc abd abf abj"
  check: check_password(test6, true) == true
  const test7 = "iiii oiii ooii oooi oooo"
  check: check_password(test7, true) == true
  const test8 = "oiii ioii iioi iiio"
  check: check_password(test8, true) == false

proc run_input() =
  const input = "input.txt"
  const data = slurp(input)

  let pwords = filterIt(mapIt(splitLines(data), it), len(it) > 0)

  echo "Number of total passwords = $#" % $len(pwords)
  let valid1 = check_lst_of_passwords(pwords)
  echo "(Part 1): The number of valid passwords is = ", valid1

  let valid2 = check_lst_of_passwords(pwords, true)
  echo "(Part 2): The number of valid passwords is = ", valid2
  
proc main() =
  run_tests()
  echo "All tests passed successfully. Result is (probably) trustworthy."
  run_input()

when isMainModule:
  main()
