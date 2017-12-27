import strutils

proc main() =
  var
    h = 0
    i = 0
    f = 1
  for b in countup(109900, 126900, 17):
    echo "iterations done ", i, " b is ", b
    for d in 2..<b:
      if b mod d == 0:
        inc h
        break
    inc i
  echo h

proc loop1_while(a, b, c, d, e, f, g, h: var int) {.inline.} =
  while e != b:
    if d * e == b:
      f = 0
      # return if we found this case
      return
    if d * e > b: break
    inc e

proc loop1(a, b, c, d, e, f, g, h: var int) {.inline.} =
  if d * e == b:
    f = 0
  if d * e > b:
    # in this case we can break early, no matter what vaue f is.
    # if f != 0 now, won't change anymore, since d * e == b cannot
    # be reached anymore anyways. Else we can break early since all
    # that this function will do, has happened anyways. 
    return
  inc e
  if e != b:
    loop1(a, b, c, d, e, f, g, h)
  # else we return
  
proc loop2(a, b, c, d, e, f, g, h: var int) {.inline.} =
  e = 2
  # start loop 1
  loop1(a, b, c, d, e, f, g, h)
  inc d
  if d != b:
    loop2(a, b, c, d, e, f, g, h)

proc loop3(a, b, c, d, e, f, g, h: var int) {.inline.} =
  f = 1
  d = 2
  # start loop2()
  loop2(a, b, c, d, e, f, g, h)
  if f == 0:
    inc h
  echo "Vars at end of loop 3: "
  echo "a = $#, b = $#, c = $#, d = $#, e = $#, f = $#, g = $#, h = $#" % [$a, $b, $c, $d, $e, $f, $g, $h]    
  if b != c:
    b += 17
    loop3(a, b, c, d, e, f, g, h)
  
  
proc implement_logic() =
  # set beginning vars
  var
    a = 1
    b = 99
    c = b
    d = 0
    e = 0
    f = 0
    g = 0
    h = 0
  b *= 100
  b += 100_000
  c = b
  c += 17_000

  # start most outer loop
  loop3(a, b, c, d, e, f, g, h)
  echo "h is now = ", h


when isMainModule:
  main()
  #implement_logic()


## OH. MY. FUCKING. GOD. I misread the sub statements for HOURS and hours.
## instead of reading sub b -100_000 etc. as one should as add b 100_000
## fuck.
## The following is the raw implementation of the code, without any
## optimizations
# proc loop1(a, b, c, d, e, f, g, h: var int) =
#   #echo "Vars at start of loop 1: "
#   #echo "a = $#, b = $#, c = $#, d = $#, e = $#, f = $#, g = $#, h = $#" % [$a, $b, $c, $d, $e, $f, $g, $h]
#   g = d
#   g *= e
#   g -= b
#   if g == 0:
#     f = 0
#   dec e
#   g = e
#   g -= b
#   if g != 0:
#     loop1(a, b, c, d, e, f, g, h)
#   # else we return
  
# proc loop2(a, b, c, d, e, f, g, h: var int) =
#   #echo "Vars at start of loop 2: "
#   #echo "a = $#, b = $#, c = $#, d = $#, e = $#, f = $#, g = $#, h = $#" % [$a, $b, $c, $d, $e, $f, $g, $h]
#   e = 2
#   # start loop 1
#   loop1(a, b, c, d, e, f, g, h)
#   dec d
#   g = d
#   g -= b
#   if g != 0:
#     loop2(a, b, c, d, e, f, g, h)

# proc loop3(a, b, c, d, e, f, g, h: var int) =
#   echo "Vars at start of loop 3: "
#   echo "a = $#, b = $#, c = $#, d = $#, e = $#, f = $#, g = $#, h = $#" % [$a, $b, $c, $d, $e, $f, $g, $h]
#   f = 1
#   d = 2
#   # start loop2()
#   loop2(a, b, c, d, e, f, g, h)
#   if f == 0:
#     dec h
#   g = b
#   g -= c
#   if g == 0:
#     return
#   b -= 17
#   loop3(a, b, c, d, e, f, g, h)
  
# proc implement_logic() =
#   # set beginning vars
#   var
#     a = 1
#     b = 99
#     c = b
#     d = 0
#     e = 0
#     f = 0
#     g = 0
#     h = 0
#   b *= 100
#   b -= 100_000
#   c = b
#   c -= 17_000

#   # start most outer loop
#   loop3(a, b, c, d, e, f, g, h)
#   echo "h is now = ", h
  
  
  
