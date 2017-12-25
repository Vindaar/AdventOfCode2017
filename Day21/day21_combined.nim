import sequtils, strutils, algorithm, unittest, times, sets, math, sets, tables, future

proc `$$`(rule: seq[string]): string =
  # pretty print a rule
  result = "\n"
  for i in 0..rule.high:
    result &= $rule[i] & "\n"

proc rot90(rule: seq[string]): seq[string] =
  # proc to rotate a rule by 90 degrees
  # simply assign rule to result, will be overwritten
  # simply takes care of having to alloc space in correct
  # sizes
  result = rule
  for i in 0..rule.high:
    for j in 0..rule.high:
      result[i][j] = rule[rule.high-j][i]

proc flip_horizontal(rule: seq[string]): seq[string] =
  # proc to flip rules horizontally
  result = rule
  for i in 0..rule.high:
    result[i] = foldl(reversed(rule[i]), $a & $b, "")

proc flip_vertical(rule: seq[string]): seq[string] =
  # proc to flip rules vertically
  result = rule
  for i in 0..rule.high:
    result[i] = rule[rule.high - i]

iterator rot90s(rule: seq[string]): seq[string] =
  var rule_rot = rule
  for _ in 0..<3:
    rule_rot = rot90(rule_rot)
    yield rule_rot    

proc create_rules(input: seq[string]): Table[seq[string], seq[string]] =
  # function using input, which creates all available rules based
  # on group operations of the lattice group with finite sized grid
  # need to consider rotations and reflections
  result = initTable[seq[string], seq[string]]()

  # first parse the input rules
  var rules_in  = mapIt(input, it.split(" => ")[0].split("/"))
  var rules_out = mapIt(input, it.split(" => ")[1].split("/"))  
  echo rules_in
  echo rules_out
  # given rules input and output, generate all possible
  # independent rotations / reflections of the inputs. Output
  # remains constant for each
  let rules_zip = zip(rules_in, rules_out)
  
  for rule_z in rules_zip:
    let (rule_in, rule_out) = rule_z
    # add base rule in -> out
    # NOTE: for symmetry reasons we will 'try' to add
    # many rotated / flipped rules, which are already part
    # of the ruleset. However, filtering out the examples
    # which are equivalent to ones already in the set...
    # hashing is fast enough...
    result[rule_in] = rule_out
    for rule_rot in rot90s(rule_in):
      result[rule_rot] = rule_out

    let rule_h = flip_horizontal(rule_in)
    for rule_rot in rot90s(rule_h):
      result[rule_rot] = rule_out

    let rule_v = flip_vertical(rule_in)
    for rule_rot in rot90s(rule_v):
      result[rule_rot] = rule_out

    let rule_vh = flip_vertical(flip_horizontal(rule_in))
    for rule_rot in rot90s(rule_vh):
      result[rule_rot] = rule_out
  echo len(rules_in)
  echo len(result)

proc replace_subgrids(grid: seq[string],
                      subgrid_size, sub_sqs: int,
                      rules: Table[seq[string], seq[string]]): seq[seq[string]] =
  # first create rules (define as global, so only done once)
  result = newSeq[seq[string]](sub_sqs * sub_sqs)
  for j in 0..<sub_sqs:
    for k in 0..<sub_sqs:
      # define starting and ending indices to extract
      # the subgrids
      let
        row_si = j * subgrid_size
        row_ei = j * subgrid_size + (subgrid_size - 1)
        col_si = k * subgrid_size                     
        col_ei = k * subgrid_size + (subgrid_size - 1)
        # extract subgrids using indices
        sub_sq = mapIt(grid[row_si..row_ei], it[col_si..col_ei])
      # given our sub square, get the proper replacement
      # from the rule table
      result[j * sub_sqs + k] = rules[sub_sq]

proc join_subgrids(subgrids: seq[seq[string]], sub_sqs, stepping: int): seq[string] =
  # newgrid to store intermediate grid
  result = @[] 
  for j in 0..<(sub_sqs):
    let
      # start index subgrids
      s_sg = j * sub_sqs
      # end index subgrids
      e_sg = j * sub_sqs + (sub_sqs - 1)
      # extract subgrids we're combining first
      local_subgrids = subgrids[s_sg..e_sg]
    var thisgrid: seq[string] = mapIt(toSeq(0..<stepping), "")
    for s in local_subgrids:
      for i in 0..<stepping:
        thisgrid[i] &= s[i]
    result.add(thisgrid)

proc calc_nonzero_entries(input: seq[string], rounds = 5): int =
  const start_grid = """
.#.
..#
###
"""
  var grid: seq[string] = @[]
  grid = start_grid.strip.splitLines
  let rules = create_rules(input)
  
  for i in 0..<rounds:
    echo "Starting round ", i
    var subgrid_size = 0
    if len(grid) mod 2 == 0:
      subgrid_size = 2
    elif len(grid) mod 3 == 0:
      subgrid_size = 3
    # perform split in 3s
    
    let
      sub_sqs = len(grid) div subgrid_size
      subgrids = replace_subgrids(grid, subgrid_size, sub_sqs, rules)
    # now we need to deal with the ugly part: we have a seq of
    # sub squares, which needs to be put back into a single square
    # i.e. join the squares
    # get size of one subsquare to know how far to step
    let stepping = subgrids[0].len

    if sub_sqs > 0:
      grid = join_subgrids(subgrids, sub_sqs, stepping)
    else:
      # in this case only had one subgrid, take it
      grid = subgrids[0]
    
  echo "Resulting grid is ", $$grid
  result = filterIt(foldl(grid, a & b, ""), it == '#').len
  echo result
      
proc run_tests() =
  const input1 = """
../.# => ##./#../...
.#./..#/### => #..#/..../..../#..#
"""
  check: calc_nonzero_entries(input1.strip.splitLines, 2) == 12

proc run_input() =
  let t0 = epochTime()
  const input = slurp("input.txt").strip.splitLines
  let non_zero = calc_nonzero_entries(input)
  let non_zero_18 = calc_nonzero_entries(input, 18)  
  
  echo "(Part 1): The number of non-zero elements after 5 iterations = ", non_zero
  echo "(Part 2): Number of pixels on after 18 iterations = ", non_zero_18
  echo "Solutions took $#" % $(epochTime() - t0)
  
proc main() =
  run_tests()
  echo "All tests passed successfully. Result is (probably) trustworthy."
  run_input()
  
when isMainModule:
  main()
