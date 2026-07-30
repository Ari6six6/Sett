#!/usr/bin/env python3
"""Read runs/ab-<spec>.tsv and say whether a difference is real or luck.

ab.sh reports totals. Totals hide the thing that matters. A gym where every
point is a coin flip and a gym where six points are solid and two are broken
can print the same number, and they mean opposite things.

So this splits every point into three buckets:

  SOLID    passes in every run of both arms      — measures nothing, costs time
  DEAD     fails in every run of both arms       — measures nothing, or is broken
  NOISY    flips within an arm                   — cannot support any claim
  SIGNAL   stable within each arm, differs across — the only rows that mean anything

Only SIGNAL rows may be used to argue that a law did something. If there are
none, the honest answer is "no effect detected at this n", and the size of the
NOISY bucket says how many runs would have been needed to see one.

usage: ./ab-analyse.py <spec>
"""
import sys, pathlib, collections, statistics

spec = sys.argv[1] if len(sys.argv) > 1 else "code-sett-8"
p = pathlib.Path(f"/home/michael/SETT-repo/runs/ab-{spec}.tsv")
if not p.exists():
    sys.exit(f"no such file: {p}")

# arm -> rep -> id -> verdict
d = collections.defaultdict(lambda: collections.defaultdict(dict))
for line in p.read_text().splitlines():
    if not line.strip():
        continue
    arm, rep, pid, verdict = line.split("\t")
    d[arm][rep][pid] = verdict

arms = sorted(d)
ids = sorted({i for a in arms for r in d[a] for i in d[a][r]}, key=lambda x: int(x))

def rate(arm, pid):
    reps = d[arm]
    got = [reps[r].get(pid) for r in sorted(reps) if pid in reps[r]]
    return sum(1 for g in got if g == "PASS"), len(got)

print(f"spec: {spec}")
for a in arms:
    print(f"  arm {a}: {len(d[a])} run(s)")
print()

hdr = f"{'id':<4}" + "".join(f"{'arm '+a:<10}" for a in arms) + "bucket"
print(hdr)
print("-" * len(hdr))

buckets = collections.Counter()
signal_rows = []

for pid in ids:
    cells, fracs, stable = [], [], True
    for a in arms:
        n, tot = rate(a, pid)
        cells.append(f"{n}/{tot}")
        fracs.append(n / tot if tot else 0.0)
        if tot and 0 < n < tot:
            stable = False

    if not stable:
        b = "NOISY"
    elif all(f == 1.0 for f in fracs):
        b = "SOLID"
    elif all(f == 0.0 for f in fracs):
        b = "DEAD"
    else:
        b = "SIGNAL"
        signal_rows.append((pid, cells))

    buckets[b] += 1
    print(f"{pid:<4}" + "".join(f"{c:<10}" for c in cells) + b)

print()
for a in arms:
    totals = [sum(1 for v in d[a][r].values() if v == "PASS") for r in sorted(d[a])]
    mean = statistics.mean(totals) if totals else 0
    spread = f"{min(totals)}–{max(totals)}" if totals else "—"
    print(f"arm {a}: runs {totals}  mean {mean:.2f}  spread {spread}")

print()
print(f"SOLID {buckets['SOLID']}   DEAD {buckets['DEAD']}   "
      f"NOISY {buckets['NOISY']}   SIGNAL {buckets['SIGNAL']}")
print()

if buckets["SIGNAL"] == 0:
    print("VERDICT: no effect detected.")
    print(f"  {buckets['NOISY']} of {len(ids)} points flip WITHIN an arm, so run-to-run")
    print("  variance — not the treatment — dominates this measurement. Any story")
    print("  told about the difference in totals would be a story about luck.")
else:
    print("VERDICT: candidate signal on these points, stable within each arm:")
    for pid, cells in signal_rows:
        print(f"  point {pid}: " + "  ".join(f"{a}={c}" for a, c in zip(arms, cells)))
    print("  Stable at this n is not the same as real. Confirm before believing.")
