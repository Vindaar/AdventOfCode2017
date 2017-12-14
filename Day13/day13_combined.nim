import sequtils, strutils, future, times, unittest

proc get_scan_range_zip(layers: seq[string]): seq[tuple[a, b:int]] =
  # proc to generate zip of depths w/ scanners and corresponding ranges
  let
    depths = mapIt(layers, parseInt(strip(split(it, ':')[0])))
    ranges = mapIt(layers, parseInt(strip(split(it, ':')[1])))
  result = zip(depths, ranges)

proc calc_firewall_severity(zipped: seq[tuple[a, b: int]]): int =
  # proc to calc cost of traversing firewall without delay
  let cost = mapIt(zipped) do: 
    if it[0] mod (2 * (it[1] - 1)) == 0:
      it[0] * it[1]
    else:
      0
  result = foldl(cost, a + b)

proc firewall_seen(zipped: seq[tuple[a, b: int]], delay = 0): bool =
  # proc to check whether we're seen with the current delay
  let seen = any(zipped) do (x: tuple[a, b: int]) -> bool:
    result = (x.a + delay) mod (2 * (x.b - 1)) == 0
  result = seen

proc calc_delay_unseen(zipped: seq[tuple[a, b:int]], delay = 0): int =
  # proc to calculate the delay to traverse without being seen
  if firewall_seen(zipped, delay):
    result = calc_delay_unseen(zipped, delay + 1)
  else:
    result = delay

proc run_tests() =
  const layers = """0: 3
1: 2
4: 4
6: 4"""
  const zipped = get_scan_range_zip(splitLines(layers))
  check: calc_firewall_severity(zipped) == 24
  check: calc_delay_unseen(zipped) == 10
  
proc run_input() =

  let t0 = epochTime()
  const input = "input.txt"
  const layers = splitLines(strip(slurp(input)))
  const zipped = get_scan_range_zip(layers)
  const severity = calc_firewall_severity(zipped)
  let delay = calc_delay_unseen(zipped)

  echo "(Part 1): The total severity of the travel through the firewall is = ", severity
  echo "(Part 2): The necessary delay to stay undetected is = ", delay
  echo "Solutions took $#" % $(epochTime() - t0)
  
proc main() =
  run_tests()
  echo "All tests passed successfully. Result is (probably) trustworthy."
  run_input()
  
when isMainModule:
  main()
