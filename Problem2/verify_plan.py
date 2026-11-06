# Simulates a plan step by step on the grounded problem and checks the goal.
# usage: python verify_plan.py Domain.pddl Problem.pddl plan_file
import sys
from pyperplan.pddl.parser import Parser
from pyperplan import grounding

domain_file, problem_file, plan_file = sys.argv[1], sys.argv[2], sys.argv[3]

parser = Parser(domain_file, problem_file)
domain = parser.parse_domain()
problem = parser.parse_problem(domain)
task = grounding.ground(problem)

ops = {op.name: op for op in task.operators}

steps = []
for line in open(plan_file):
    line = line.strip().lower()
    if line and not line.startswith(";"):
        steps.append(line)

state = set(task.initial_state)
ok = True
for i, name in enumerate(steps, 1):
    if name not in ops:
        print(f"step {i}: {name}  -> unknown or never applicable action")
        ok = False
        break
    op = ops[name]
    if not op.applicable(state):
        missing = op.preconditions - state
        print(f"step {i}: {name}  -> NOT applicable, missing {sorted(missing)}")
        ok = False
        break
    state = op.apply(state)
    print(f"step {i:>2}: {name}")

def show(prefix):
    return sorted(f for f in state if f.startswith(prefix))

print("\nFinal state (relevant facts):")
print("  rover   :", show("(rover-at"))
print("  rocks   :", show("(rock-at-area"))
print("  bays    :", show("(storage-empty") + show("(storage-filled"))
print("  drill   :", show("(has-drill") + show("(drill-at"))

missing_goals = task.goals - state
print("\nPlan executable:", ok)
print("Goal satisfied :", ok and not missing_goals)
if missing_goals:
    print("Missing goal facts:", sorted(missing_goals))
