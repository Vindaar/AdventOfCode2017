import strutils, times, tables, unittest

proc calc_score_of_stream(s: string): (int, int) =
  var
    score = 0
    tot_score = 0
    in_garbage = false
    garbage_cnt = 0
    i = 0
  while i < len(s):
    let c = s[i]
    case c
    of '!':
      # jump over next character, as we ignore it
      inc i, 2
      continue
    of '{':
      # increase score of the current group
      if in_garbage == false:
        inc score
      else:
        # if in garbage, count character
        inc garbage_cnt
    of '}':
      # add current group to group table
      if in_garbage == false:
        inc tot_score, score
        if score > 0:
          dec score
      else:
        # if in garbage, count character
        inc garbage_cnt  
    of '<':
      if in_garbage == false:
        in_garbage = true
      else:
        # if in garbage, count character
        inc garbage_cnt
    of '>':
      # always stops garbage, because cancels by ! are managed by
      # jumping above next char in stream
      in_garbage = false
    else:
      if in_garbage == true:
        inc garbage_cnt
    inc i

  result = (tot_score, garbage_cnt)

proc run_tests() =
  const s1 = "{}"
  check: calc_score_of_stream(s1)[0] == 1
  const s2 = "{{{}}}"
  check: calc_score_of_stream(s2)[0] == 6
  const s3 = "{{},{}}"
  check: calc_score_of_stream(s3)[0] == 5
  const s4 = "{{{},{},{{}}}}"
  check: calc_score_of_stream(s4)[0] == 16
  const s5 = "{<a>,<a>,<a>,<a>}"
  check: calc_score_of_stream(s5)[0] == 1
  const s6 = "{{<ab>},{<ab>},{<ab>},{<ab>}}"
  check: calc_score_of_stream(s6)[0] == 9
  const s7 = "{{<!!>},{<!!>},{<!!>},{<!!>}}"
  check: calc_score_of_stream(s7)[0] == 9
  const s8 = "{{<a!>},{<a!>},{<a!>},{<ab>}}"
  check: calc_score_of_stream(s8)[0] == 3


  const s9 = "<>"
  check: calc_score_of_stream(s9)[1] == 0
  const s10 = "<random characters>"
  check: calc_score_of_stream(s10)[1] == 17
  const s11 = "<<<<>"
  check: calc_score_of_stream(s11)[1] == 3
  const s12 = "<{!>}>"
  check: calc_score_of_stream(s12)[1] == 2
  const s13 = "<!!>"
  check: calc_score_of_stream(s13)[1] == 0
  const s14 = "<!!!>>"
  check: calc_score_of_stream(s14)[1] == 0
  const s15 = """<{o"i!a,<{i<a>"""
  check: calc_score_of_stream(s15)[1] == 10



proc run_input() =

  let t0 = cpuTime()      
  const input = "input.txt"
  let stream = strip(readFile(input))
  let (score, garbage) = calc_score_of_stream(stream)
    
  echo "(Part 1): The score of the stream is = ", score
  echo "(Part 2): The number of characters in the garbage is = ", garbage
  echo "Solutions took $#" % $(cpuTime() - t0)
  
proc main() =
  run_tests()
  echo "All tests passed successfully. Result is (probably) trustworthy."
  run_input()

when isMainModule:
  main()


