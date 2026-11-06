# AI Group Assignment 2

## Group members

| Name | Roll No | Part |
|---|---|---|
| | | Problem 1, Part A (expert network, Q1 - Q7, explaining away, Q1 by hand) |
| | | Problem 1, Parts B + C (d-separation, ancestral sampling) |
| | | Problem 1, Parts D + E (MLE / BDeu learning, comparison, plot) |
| Sumagna Das | B24CS044 | Problem 2 (PDDL rover planning) |
| | | Problem 3 (Prolog resolution refutation) |

## Problem 1 - Bayesian Network (`Problem1/`)

`Problem1_BayesianNetwork.ipynb` covers Parts A to E and is already executed. To rerun:

```
pip install -r Problem1/requirements.txt
jupyter notebook Problem1/Problem1_BayesianNetwork.ipynb      (Run All)
```

Random seed is 42. The generated datasets are saved as `smart_home_500.csv`, `smart_home_5000.csv` and `smart_home_20000.csv`. The two plots are also saved as PNGs.

`Hand-Work.pdf` is the Q1 calculation done by hand (Part A, Task 6).

## Problem 2 - Mars Rover PDDL (`Problem2/`)

Planner: Fast Downward (https://github.com/aibasel/downward, build with `./build.py`).

```
cd Problem2
FD=/path/to/downward/fast-downward.py ./run_planner.sh
```

This runs GBFS + FF (satisficing) and A* + LM-cut (optimal) on both problems and saves plans, logs and the step by step verification in `out/`. `verify_plan.py` needs `pip install pyperplan`. The analysis is in `Analysis_Report.docx`.

## Problem 3 - Resolution Refutation (`Problem3/`)

```
swipl -g run -t halt Problem3/royal_archive_access.pl
```

Prints every transformation stage (Steps 1 to 7) and then the resolution steps down to the empty clause. `proof_output.txt` is the output of that command.

## Screenshots

Each problem has its own `screenshots/` folder:

- `Problem1/screenshots/`: CPTs and the sum-to-1 check, the network graph, Q1 - Q7, d-separation results, sampling counts, learned AC CPT, comparison tables, error plot
- `Problem2/screenshots/`: planner output for all four runs, the optimal plan, plan verification for both scenarios
- `Problem3/screenshots/`: the CNF steps and the resolution proof ending in the empty clause
