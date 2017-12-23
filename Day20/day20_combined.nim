import sequtils, strutils, unittest, times, sets, math, sets, tables, future

proc particle_accelerator_hah(particles: seq[string]): int =
  # return the particle with the lowest absolute acceleration
  # as this will stay closest to (0, 0) in the long run
  let acc_vec = mapIt(particles, split(it, 'a')[1].strip(chars = {'=', '<', '>'}).split(','))
  let acc_abs = mapIt(acc_vec, sqrt(foldl(it, a + pow(parseFloat(b), 2), 0.0)))
  result = filterIt(toSeq(0..acc_vec.high), acc_abs[it] == min(acc_abs))[0]

proc dist(p1, p2: seq[int]): float =
  result = sqrt(pow(float(p1[0] - p2[0]), 2) + pow(float(p1[1] - p2[1]), 2) + pow(float(p1[2] - p2[2]), 2))
  
proc all_distance_increase(pos_vec: Table[int, seq[int]], clear = false): bool =
  var
    cmp_with {.global.} = initTable[int, seq[int]]()
    prev_dists {.global.} = initTable[(int, int), float]()
    dists = initTable[(int, int), float]()
  if cmp_with.len == 0 or clear == true:
    cmp_with = pos_vec
    if clear == true:
      prev_dists = initTable[(int, int), float]()
    return false
  else:
    # first iterate through all n^2 distances and calculate
    # them so that we can compare with previous distances
    for k in keys(pos_vec):
      for r in keys(cmp_with):
        let dist_b = dist(pos_vec[k], cmp_with[r])
        dists[(k, r)] = dist_b
    # set cmp_with to current value of pos_vec
    cmp_with = pos_vec
    if prev_dists.len == 0:
      # in first iter, simply accept current dist as new prev
      # and return false
      prev_dists = dists      
      return false
    else:
      # now actually check all distances, whether any 'come closer'
      let zip_dists = zip(toSeq(values(dists)), toSeq(values(prev_dists)))
      result = all(zip_dists) do (x: tuple[a, b: float]) -> bool:
        x.a > x.b
      prev_dists = dists
    
proc remove_colliding_particles(particles: seq[string]): int =
  # acceleration remains constant, calc once
  var pos_vec: Table[int, seq[int]] = initTable[int, seq[int]]()
  var vel_vec: Table[int, seq[int]] = initTable[int, seq[int]]()
  var acc_vec: Table[int, seq[int]] = initTable[int, seq[int]]()

  var i = 0
  for p in particles:
    let rp = p.split('>')
    let
      p_vec = mapIt(rp[0].strip(chars = {'p', '=', '<', ','} + Whitespace).split(','), parseInt(it))
      v_vec = mapIt(rp[1].strip(chars = {'v', '=', '<', ','} + Whitespace).split(','), parseInt(it))
      a_vec = mapIt(rp[2].strip(chars = {'a', '=', '<', ','} + Whitespace).split(','), parseInt(it))
    pos_vec[i] = p_vec
    vel_vec[i] = v_vec
    acc_vec[i] = a_vec
    inc i
  
  var tick_count = 0
  while true:
    # now need to first update velocity of each particle
    # then position
    var pos_set = initSet[seq[int]]()
    var dup_set = initSet[seq[int]]()
    let n_part = pos_vec.len
    
    for it in keys(pos_vec):
      let
        x = pos_vec[it][0]
        y = pos_vec[it][1]
        z = pos_vec[it][2]
        xv = vel_vec[it][0] + acc_vec[it][0]
        yv = vel_vec[it][1] + acc_vec[it][1]
        zv = vel_vec[it][2] + acc_vec[it][2]
      vel_vec[it] = @[xv, yv, zv]
      pos_vec[it] = @[x + xv, y + yv, z + zv]
      if pos_vec[it] in pos_set:
        dup_set.incl(pos_vec[it])
      else:
        pos_set.incl(pos_vec[it])
    # given new pos, check if duplicates exist
    if pos_set.card != n_part:
      let dup_inds = filterIt(toSeq(keys(pos_vec)),
                              pos_vec[it] in dup_set)
      # remove elements with this index
      for dup in dup_inds:
        pos_vec.del(dup)
        vel_vec.del(dup)
        acc_vec.del(dup)
    #tick_count > 100000: #increasing_dist(pos_vec, pos_vec_old)
    var dist_increased = false
    if tick_count == 0:
      dist_increased = all_distance_increase(pos_vec, true)
    else:
      dist_increased = all_distance_increase(pos_vec)      
    if len(pos_vec) == 1 or dist_increased == true:
      result = len(pos_vec)
      break
    if tick_count mod 100000 == 0:
      echo "$# steps done" % $tick_count
    inc tick_count

proc run_tests() =
  const input1 = """
p=< 3,0,0>, v=< 2,0,0>, a=<-1,0,0>
p=< 4,0,0>, v=< 0,0,0>, a=<-2,0,0>
"""
  const input2 = """
p=<-6,0,0>, v=< 3,0,0>, a=< 0,0,0>
p=<-4,0,0>, v=< 2,0,0>, a=< 0,0,0>
p=<-2,0,0>, v=< 1,0,0>, a=< 0,0,0>
p=< 3,0,0>, v=<-1,0,0>, a=< 0,0,0>
"""
  check: particle_accelerator_hah(input1.strip.splitLines) == 0
  check: remove_colliding_particles(input2.strip.splitLines) == 1

proc run_input() =
  let t0 = epochTime()
  const input = slurp("input.txt").strip.splitLines
  let closest_particle = particle_accelerator_hah(input)
  let non_colliding_particles = remove_colliding_particles(input)
  
  echo "(Part 1): The particle with the lowest absolute acceleration is = ", closest_particle
  echo "(Part 2): The number of non-colliding particles is = ", non_colliding_particles
  echo "Solutions took $#" % $(epochTime() - t0)
  
proc main() =
  run_tests()
  echo "All tests passed successfully. Result is (probably) trustworthy."
  run_input()
  
when isMainModule:
  main()
