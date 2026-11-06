# Problem 2 - Mars Rover Sample Collection using PDDL

**Group members:** 
| Name | Roll |
| Sumagna Das | B24CS044 |
| Parth Bhosale | B24CS033 |
| Zala Vedant | B24CS054 |
| Kanishk Nandeshwar | B24DS010 |


## Files

| File | What it is |
|---|---|
| `Domain.pddl` | types, predicates and the 5 actions (move, pick-drill, collect-soft, collect-hard, deposit) |
| `Problem.pddl` | base scenario, 5 rocks |
| `Problem_extended.pddl` | 7 rocks, Base <-> SiteB closed |
| `run_planner.sh` | runs both planner configurations on both problems |
| `verify_plan.py` | step by step plan simulator used for goal verification |
| `out/` | plans (`*.plan`), full planner logs (`*.log`) and simulator output (`*_verify.txt`) |

## Task 1 and 2 - Modelling choices

- Only `:strips` and `:typing` are used, so there are no negative preconditions. Instead of `(not (in-bay ...))` the domain keeps a positive fact `(bay-empty ?b)` that is deleted on collect and added back on deposit. Soft and hard are also two separate positive predicates.
- Because of that, "hard rocks need the drill" is done with two collect actions. `collect-soft` needs `(soft ?k)` and `collect-hard` needs `(hard ?k)` plus `(has-drill ?r)`.
- Routes are directed facts `(path ?from ?to)`. Every two-way route is written as two facts and the slope is only `(path siteC siteD)`, so SiteD to SiteC simply does not exist as a move.
- `pick-drill` deletes `(drill-at drill1 siteE)` and adds `(has-drill curiosity)`. There is no action to drop it, so the rover keeps it for the rest of the mission.
- The two bays are linked to the rover with `(bay-of bay ?r)`, so each bay holds one rock and the rover can carry at most two.
- The extended goal in the PDF only lists the rocks and the rover. I did not add `bay-empty` to it because it follows anyway: a rock at Base is not in a bay, and every rock is at Base.

## Task 3 - Plan generation

Planner: **Fast Downward** (built from the aibasel/downward repository).

- Satisficing: `lazy_greedy([ff()], preferred=[ff()])`, greedy best-first search with the FF heuristic
- Optimal: `astar(lmcut())`, A* with the admissible LM-cut heuristic

| Scenario | Configuration | Plan length (= total actions) | States expanded | Search time | Total time |
|---|---|---|---|---|---|
| Base | GBFS + FF | 33 | 106 | 0.0025 s | 0.0073 s |
| Base | A* + LM-cut | **25** | 5,774 | 0.821 s | 0.826 s |
| Extended | GBFS + FF | 53 | 170 | 0.004128 s | 0.009932 s |
| Extended | A* + LM-cut | **40** | 2,230,075 | 374.4 s | 374.4 s |

Every action has unit cost, so plan length and the number of actions are the same thing. The full action sequences are in `out/*.plan`. The optimal base plan is:

```
 1 move base -> siteB              14 collect-hard rock5 -> bay1 (siteF)
 2 collect-soft rock2 -> bay1      15 move siteF -> siteE
 3 move siteB -> siteD             16 move siteE -> siteC
 4 collect-soft rock4 -> bay2      17 collect-hard rock3 -> bay2 (siteC)
 5 move siteD -> siteB             18 move siteC -> siteA
 6 move siteB -> base              19 move siteA -> base
 7 deposit rock2 (bay1)            20 deposit rock3 (bay2)
 8 deposit rock4 (bay2)            21 deposit rock5 (bay1)
 9 move base -> siteA              22 move base -> siteA
10 move siteA -> siteC             23 collect-soft rock1 -> bay1
11 move siteC -> siteE             24 move siteA -> base
12 pick-drill drill1 (siteE)       25 deposit rock1 (bay1)
13 move siteE -> siteF
```

## Task 4 - Goal verification

`verify_plan.py` grounds the problem with pyperplan, starts from the initial state and applies the plan one action at a time. Before every step it checks the preconditions, and at the end it checks every goal fact. All four plans pass. Final state of the optimal base plan:

```
rover : (rover-at curiosity base)
rocks : (rock-at rock1 base) (rock-at rock2 base) (rock-at rock3 base) (rock-at rock4 base) (rock-at rock5 base)
bays  : (bay-empty bay1) (bay-empty bay2)
drill : (has-drill curiosity)
Plan executable: True
Goal satisfied : True
```

The extended plans end with all seven rocks at Base, both bays empty and the rover at Base (see `out/Problem_extended_*_verify.txt`).

## Task 6 - Plan analysis

**1. Satisficing vs optimal plan length.** In the base scenario GBFS found a 33 step plan and A* found 25, and in the extended one GBFS found 51 against the optimal 40. GBFS only looks at the heuristic value and grabs whatever looks closest to the goal right now, so it delivers rocks one at a time. In the base plan it never carries two rocks at once, and in the extended plan it uses both bays only on the very last trip to SiteF. Each extra round trip costs 2 to 8 moves. A* orders nodes by g + h with an admissible heuristic, so it cannot stop until it has proven nothing shorter exists, which is why its plans are optimal. The price is search effort: 5,776 vs 68 expanded states in the base case, and 2.23 million vs 96 in the extended case, where A* took about 147 seconds while GBFS took a few milliseconds. With 7 rocks the number of possible bay contents and rock locations blows up, and LM-cut is not informed enough to prune most of it.

**2. Bays and the drill in the optimal plan.** The optimal plan always fills both bays before going back, so there are only three trips that collect rocks. Trip 1 (steps 1 to 8) goes through the B side and grabs Rock2 and Rock4, both soft, so no drill is needed. Trip 2 (steps 9 to 21) goes Base, A, C, E, picks the drill at SiteE (step 12), then Rock5 at SiteF and Rock3 at SiteC on the way back, both hard. Trip 3 is a short run to SiteA for Rock1. The drill is picked up exactly when it is first needed and while the rover is already passing SiteE on its way to SiteF. Rock1 is left for last because it is one step from Base and only costs 4 actions on its own. Interestingly, A* did not collect Rock1 on the way out of trip 2 even though it passes SiteA, because then a bay would be full and it could not bring back both hard rocks in one trip.

**3. Extended scenario.** With Base <-> SiteB closed, SiteB can only be reached from SiteD, and SiteD can be entered either from SiteE or down the one-way slope from SiteC. The optimal plan goes Base, A, C, then **uses the slope C -> D**, collects Rock4, goes D -> B for Rock2, then has to come back up through D -> E (it cannot go D -> C) and picks up the drill at SiteE on the way, then E -> C -> A -> Base. So the one-way route is used once, and it is what makes the outbound trip to the B/D side short. The remaining trips are the two hard rocks at SiteF together (Rock5 and Rock7), then Rock3 at SiteC with Rock6 at SiteE, and finally Rock1. The GBFS plan uses the slope twice (once for Rock4, once for Rock2) because it made separate trips for them.
