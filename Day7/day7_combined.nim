import sequtils, strutils, sets, os, unittest, times, tables, future

type
  Stack = object
    weight*: int
    children*: HashSet[string]

proc newStack(weight: int, children = initSet[string]()): Stack =
  result.weight = weight
  result.children = children

proc calc_weight_of_subtree(tree: var Table[string, Stack], child: string): int =
  # given a program, calculate the total weight of this program and its
  # subtree and return value as an int. Done recursively down to the last leaf
  result = 0
  for ch in tree[child].children:
    result += tree[ch].weight
    result += calc_weight_of_subtree(tree, ch)

proc calc_subtree_table(tree: var Table[string, Stack], base: string): Table[string, int] =
  # calculate total weights of all subtrees of a given program and return a table
  # containing the names and weights of these subtrees
  result = initTable[string, int]()
  for child in tree[base].children:
    result[child] = calc_weight_of_subtree(tree, child) + tree[child].weight

proc calc_wrong_weight(weights: Table[string, int]): (string, int) =
  # calculate which program has the wrong weight
  let weight_vals = map(toSeq(pairs(weights)), (ch: tuple[n: string, v: int]) -> int => ch.v)
  let mean = foldl(weight_vals, a + b) div len(weight_vals)
  let diffs = mapIt(weight_vals, abs(it - mean))
  result = filterIt(zip(toSeq(keys(weights)), diffs), it[1] == max(diffs))[0]

proc determine_wrong_weight(tree: var Table[string, Stack], base: string): (string, string) =
  # given a base of a (sub-)tree, find the wrong weight in that (sub-)tree
  # returns the name of the child with the wrong weight and the weight it and its
  # subtree should have
  # returns a tuple of strings, where the second contains the program with wrong
  # weights and the first its parent

  # calculate weights of all subtrees
  let weights = calc_subtree_table(tree, base)

  if len(weights) == 0:
    # this case would only happen, if one leaf child (no children itself)
    # would have the wrong weight. Thus return base as wrong program
    result = ("", base)
  else:
    # create set of values and check length, thus we know whether
    # the wrong weight is still in a subtree or is this subtrees parent
    let hashes = toSet[int](toSeq(values(weights)))
    if len(hashes) == 1:
      # in this case parent has wrong weight
      result = ("", base)
    else:
      # final case in which there are still several parallel subtrees. find the
      # one with the `wrong` weight (all others will be the same)
      let wrong_weight = calc_wrong_weight(weights)
      # call this function recursively until either one of the other two result statements
      # returns
      result = determine_wrong_weight(tree, wrong_weight[0])
      # check whether the 2nd part of the result is the same name as the argument
      # indicates argument was program with wrong weight
      if result[1] == wrong_weight[0]:
        # set parent of wrong program as first return value
        result = (base, result[1])

proc fix_weight(tree: var Table[string, Stack], base, prog_wrong: string): int =
  # we know prog_wrong is the culprit with wrong weight. Calculate weight of children
  # in same class (subtree of base) again and compare the two weights
  let weights = calc_subtree_table(tree, base)
  var
    wrong = 0
    correct = 0
  # check weights for correct and wrong subtree weights
  for k, v in weights:
    if k == prog_wrong:
      wrong = v
    else:
      correct = v
      # break early if we already found the wrong value
      if wrong != 0:
        break
  # get individual weight of bad program
  let child_weight = tree[prog_wrong].weight
  # calculate the correct weight for prog_wrong
  result = child_weight - (wrong - correct)
  
proc find_stack_base(data: seq[string]): (string, int) =
  var
    root_name = ""
    stack = mapIt(data, split(replace(strip(it), ",", "")))
    # table storing all programs on stack
    program_table = initTable[string, Stack]()
    # set to save all programs, which are children
    allchildren = initSet[string]()

  # walk the stack to find its base
  for p in stack:
    let
      name = p[0]
      weight = parseInt(strip(p[1], chars = {'(', ')'}))
    # define set of all children of this element in the stack
    var children = initSet[string]()
    # if there's more than 2 elements, means program has children
    if len(p) > 2:
      # for all elements after `->` add to children set
      for i in 3..<len(p):
        let ch = p[i]
        children.incl(ch)
        allchildren.incl(ch)

    let s = newStack(weight, children)
    # add program to table if not contained already
    if hasKey(program_table, name) == false:
      program_table[name] = s

  # find the root node by searching for element of program_table
  # which is not in children set
  for k, v in program_table:
    if contains(allchildren, k) == false:
      root_name = k
      # break early, found what we were looking for
      break

  # given root node, traverse stack to find the node with wrong weights and
  # recursively check each subtree to locate program
  let prog_wrong_weight = determine_wrong_weight(program_table, root_name)
  # calculate the weight the program should have instead
  let correct_weight = fix_weight(program_table, prog_wrong_weight[0], prog_wrong_weight[1])

  result = (root_name, correct_weight)

proc run_tests() =
  const data = """pbga (66)
xhth (57)
ebii (61)
havc (66)
ktlj (57)
fwft (72) -> ktlj, cntj, xhth
qoyq (66)
padx (45) -> pbga, havc, qoyq
tknk (41) -> ugml, padx, fwft
jptl (61)
ugml (68) -> gyxo, ebii, jptl
gyxo (61)
cntj (57)"""
  var stack = splitLines(data)
  check: find_stack_base(stack) == ("tknk", 60)
  
proc run_input() =

  let t0 = cpuTime()      
  const input = "input.txt"
  let stack = filterIt(splitLines(readFile(input)), len(it) > 0)
  let (base, weight) = find_stack_base(stack)
    
  echo "(Part 1): The base of the stack is = ", base
  echo "(Part 2): The correct weight would be = ", weight
  echo "Solutions took $#" % $(cpuTime() - t0)
  
proc main() =
  run_tests()
  echo "All tests passed successfully. Result is (probably) trustworthy."
  run_input()

when isMainModule:
  main()
      
    
