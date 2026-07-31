# Morning brief — 2026-07-31

Written overnight while you slept. Everything below is on GitHub.

## Run this first

```sh
cd /home/michael/SETT-repo && ./sett selftest --fast
```

46 seconds. It should print `selftest: PASS`. If it does, nothing rotted
overnight and the numbers in this file are still true.

---

## The one-line state

**The gyms are sound and the model is not the bottleneck. Six things are fixed
but unproven, and proving them needs one hour of GPU.**

## What is proven

`code-10` on glm-q4, n=3: **8, 8, 9** — mean 8.33.

Points 1–7 pass **3/3**. Seven coding tasks solved reliably, three of them
computing over real corpora — 1 655 CISA KEV entries and a 25 843-object STIX
bundle. That is a capability, not a lucky afternoon.

The frontier is narrow and honest: multi-hop STIX resolution 2/3, the `jq`
point 1/3, the spec-linter 1/3.

## What is NOT proven — the whole reason to rent a box

Six fixes are written, gated, and **never run**. Each is a prediction:

| # | fix | prediction |
|---|---|---|
| 1 | `code-sett-8` p2 now states its columns | p2 has scored 0/3 in every configuration; this is the last known operator defect on it |
| 2 | `code-sett-8` p1 states the empty-file case | should stop a coin flip |
| 3 | `code-10` p10 states the id-token rule | failed reproducibly with `['3 c']` |
| 4 | `code-10` p2 states the empty-list case | should stop a coin flip |
| 5 | `stix-graph-12` names the corpus in all 12 points | **it named it in point 1 only.** Every point is a fresh process seeing one `do:` line, so 11 points never told the model which file to open. Untested, and it has never been flown |
| 6 | `debug-7`, the whole gym | brand new, never run |

## The hour that would settle it

```sh
sett birth "<vast.ai ssh string>" --model glm-q4
sett doctor                       # drift is the default state, not the exception
sett runs code-sett-8 3           # does the column fix move p2 off 0/3?
sett runs code-10 3               # does p10 move off 1/3?
sett runs debug-7 3               # can it REPAIR, not just write?
sett runs stix-graph-12 3         # first ever flight
sett leak                         # must stay clean
sett kill
```

`sett runs` keeps every rep's artifacts under `runs/archive/<spec>-repN/`, so
failures stay openable after the box is gone. That cost me two undiagnosable
points last night.

**`debug-7` is the interesting one.** Writing code and repairing code are
different skills, and nothing here has ever measured the second. It is built
from seven real bugs the model itself produced yesterday, graded by the same
checks the originals used — so the scores are directly comparable.

## What last night actually produced

Not scores. Instruments, and the defects they found in **my own work**:

| found | what it was |
|---|---|
| `smoke-3` p3 | ground truth over a deleted directory — the check **inverted**, correct answers began failing and garbage began passing |
| `SEAT.md` | the law told the model to verify itself with a tool deleted in the merge. Every gym ever run was scored under it |
| the answer key | 15 runs read the spec containing their own checks. Not exploited — luck, not design. Now structurally impossible |
| the 6-vs-4 "result" | pure noise. Four of eight points flipped inside an arm |
| `SOLID` at n=2 | point 4 was 4/4 then 0/3. The tool built to catch coin flips called one rock solid |
| `flash-100-core` p87 | `grep -qF ""` matches anything, so it passes on garbage whenever p84 failed. **22/23, not the published 23/23** |
| a VERIFY metric | reported 0% for data gyms — beautiful and false, its regex only matched `.py` |
| SHOWCASE | claimed old scores are re-checkable any time. They were not, until `sett check --out` existed |

Eight defects. **Seven of them mine, one the model's.** That ratio is the
finding of the day, and it is not the one the gym was built to produce.

## New tonight

- `sett selftest [--fast]` — every gate on every spec, plus all 14 verbs, plus rot and leak
- `sett lint` — operator defects that read as model failures
- `sett gate --broken` — gate D, for repair gyms: the broken input must fail
- `sett check --out DIR` — re-verify an archived run in place
- `sett rot` — now audits documented commands, not just paths
- `sett runs` — n runs keeping every rep's artifacts
- `behave.py` — what the model DID, from 194 transcripts
- `debug-7` + `fixtures/broken/` — the repair gym

## Housekeeping

- **The vast.ai instance may still be rented.** `km --down` stopped the server
  and tunnel; it does not destroy the instance. Check the console.
- `vault gold` verified INTACT — 15 132 files, nothing lost.
- tmux session `sett` is still up: `tmux attach -t sett`.
- 40+ commits pushed to github.com/Ari6six6/Sett.

## The honest summary

You asked whether three years and fifteen repos were wasted. Last night says
no, but not for the reason you hoped. The model was never the ceiling. **Your
instructions were**, and now there are instruments that find that out
mechanically instead of leaving you to wonder.

The badger keeps one den and digs deeper. That is the whole idea.
