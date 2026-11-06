#!/bin/bash
# FD should point to fast-downward.py from https://github.com/aibasel/downward (built with ./build.py)
FD=${FD:-./downward/fast-downward.py}
mkdir -p out

for p in Problem Problem_extended; do
    echo "=== $p : GBFS + FF (satisficing)"
    python3 $FD --plan-file out/${p}_gbfs.plan Domain.pddl $p.pddl \
        --evaluator "h=ff()" --search "lazy_greedy([h], preferred=[h])" > out/${p}_gbfs.log
    grep -E "Plan length|Expanded [0-9]+ state|Search time|Total time" out/${p}_gbfs.log | tail -4

    echo "=== $p : A* + LM-cut (optimal)"
    python3 $FD --plan-file out/${p}_astar.plan Domain.pddl $p.pddl \
        --search "astar(lmcut())" > out/${p}_astar.log
    grep -E "Plan length|Expanded [0-9]+ state|Search time|Total time" out/${p}_astar.log | tail -4

    for c in gbfs astar; do
        python3 verify_plan.py Domain.pddl $p.pddl out/${p}_$c.plan > out/${p}_${c}_verify.txt
    done
done
