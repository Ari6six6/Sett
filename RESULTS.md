# RESULTS

One row per model per gym. A point counts only if its check exited 0.
No partial credit. No SKIP.

The live version of the table below is `sett score`, computed from
`runs/*/state.tsv` rather than typed by hand. This file is the written record:
the analysis, the confounds, and the caveats a table cannot carry.

---

## 2026-07-31 box #4 — the six predictions

**Model:** GLM-4.7-Flash Q4_K_M (HauhauCS Balanced) · **Box:** 1× A100-PCIE
40 GB · **ctx:** 65536 · **n=3 per gym**

Six fixes had been written, gated, and never run. Each was recorded in
`docs/MORNING-2026-07-31.md` as a prediction *before* the box was rented. This
is what happened.

### 1 · `code-sett-8` point 2 — the point nothing could move

Its `do:` asked for a summary keyed by verdict but never said which column held
the verdict. The model had to guess, and guessed wrong, run after run:

| configuration | p2 |
|---|---|
| first 4-rep baseline | 1/4 |
| clean law | 0/3 |
| deambiguated law | 0/3 |
| repeat of clean | 0/3 |
| **columns stated in `do:`** | **2/3** |

**1 of 13 before. 2 of 3 after.** Four configurations — two different laws,
two different boxes — could not shift that point. One sentence naming the
column layout did.

Point 1 (empty-file case now stated) moved 9/13 → 3/3, pointing the same way,
but 3/3 at n=3 cannot carry a claim on its own.

**Gym totals: 8, 7, 7** — mean 7.33, against a prior best of 6.25.
Six of eight points are now SOLID at 3/3; points 2 and 7 remain NOISY.

**Confounds, stated rather than buried.** The box changed as well as the spec
text (A100 40 GB, not the RTX 6000 Ada those older numbers came from), so this
is not a clean single-variable experiment. And the spec text itself changed by
design, which means `sett score` marks the old numbers `(!)` — they were earned
against a gym text that no longer exists. That flag is correct and it applies
to this comparison too: the fix is *supported*, not *proven*, and the effect
size is not measurable at this n.

**Correction to the morning brief:** it said p2 had scored "0/3 in every
configuration". The earliest run scored 1/4. The table above is the record.

### 2 · `code-10` — the same mean, a different shape

**9, 7, 9 — mean 8.33.** Yesterday: 8, 8, 9 — mean 8.33. Identical means, and
the identity is a coincidence: the per-point picture moved in both directions.

| point | baseline | today | |
|---|---|---|---|
| 10 · spec-linter | 1/3 | **3/3 SOLID** | the id-token rule now stated |
| 4 · retry-backoff | 3/3 | 2/3 NOISY | drifted |
| 8 · stix-resolve-refs | 2/3 | 2/3 NOISY | unchanged frontier |
| 9 · cli-tool | 1/3 | **0/3 DEAD** | see below |

**Prediction 3 confirmed.** Point 10 was a coin flip and is now solid.

**Prediction 4 was untestable and should not have been written.** It aimed at
point 2's empty-list case, but point 2 scored 3/3 in every baseline run. There
was no coin flip there to fix, so no outcome today could confirm or refute it.
Writing a prediction about a point that was never observed failing is the same
error as an existence test: it cannot come out false.

**Point 9 got worse, and that is the useful part.** `sett runs` passes no
`--law`, so every rep here flew **bare** — `SEAT.md`'s "jq is NOT installed"
was never in the prompt. Point 9 reaches for `jq`, which does not exist on the
box. The earlier law A/B found "no effect detected"; this is the point that
A/B should have been measuring, and it is now 0/3 without the law. That is an
argument for the law that no aggregate score could have made.

### 3 · `stix-graph-12` — first flight, and the largest single fix

The gym had **named its corpus in point 1 only**. Every point is a fresh
process seeing one `do:` line, so eleven of twelve points never told the model
which file to open. It had never been flown.

**Rep 1: 10/12.** Eight consecutive points passing on multi-hop relationship
resolution over a 25 843-object STIX bundle — resolving `source_ref` and
`target_ref` against an index the model has to build before it can answer
anything. The two failures, points 9 and 10, are genuine traversal frontier
rather than missing instructions.

### 4 · `debug-7` — repairing is harder than writing

The repair gym, built from seven real broken files the model itself produced,
graded by the same checks the originals used. Never run until today.

**5, 5, 3 out of 7 — mean 4.33 (62%)**, against **8.33/10 (83%)** for writing
fresh code on the same box in the same hour.

| bucket | points |
|---|---|
| SOLID 3/3 | 2, 6 |
| NOISY | 1, 3, 4, 5, 7 |
| DEAD | none |

Five of seven points are coin flips. Nothing is dead, so no point is beyond
the model — but only two are reliable. **Writing code and repairing code are
different skills**, and this is the first measurement of the second one here.
The comparison is as close to controlled as this apparatus gets: same model,
same quantisation, same box, same hour, same grading checks.

## 2026-07-30 box #2 — the brief experiment

**The headline result of the day.** Model, quantisation, tasks, gates and
grading all held fixed. The only variable is three sentences of environment
fact added to the brief.

**Model:** GLM-4.7-Flash Q4_K_M · **Box:** 1× RTX 6000 Ada 48 GB · **ctx:** 65536

| brief | real (A) | correct (B) | discerning (C) | **TRUE GATES** |
|---|---|---|---|---|
| strict | 10/10 | 5/10 | 10/10 | **5 / 10** |
| guided | 10/10 | 8/10 | 10/10 | **8 / 10** |

The guided brief adds only:

```
- jq is NOT installed. Use python3 or coreutils only.
- Read the JSON structure before assuming it. A top-level object is not a
  list; KEV entries live under the "vulnerabilities" key.
- Your output must be valid bash. Do not emit prose. Do not emit fences.
```

**Prediction recorded before the run: 5/10 → 7 or 8. Result: 8.**

### Reproducibility

The strict run scored **5/10 on box #2**, identical to box #1 that morning —
different hardware (1× RTX 6000 Ada vs 2× RTX 4060 Ti), different context
(65536 vs 32768), different country. The instrument is stable.

### It is not monotone — 5 fixed, 2 broke

| point | strict | guided | |
|---|---|---|---|
| 11 · 16 · 18 · 19 · 20 | fail | **pass** | fixed |
| 22 · 89 · 90 | pass | pass | — |
| 13 | pass | **fail** | broke |
| 25 | pass | **fail** | broke |

Net +3. The two regressions matter more than the gain:

- **13** — emitted a compressed python one-liner with a leading space on the
  continuation line: `IndentationError`. Plausibly induced by the brief's own
  "prefer `test "$(...)" = "$(...)"`" hint pushing toward compression.
- **25** — compared the bare hash against the whole file with whitespace
  stripped, but the artifact holds `<hash>  <filename>`. The task says "the
  sha256sum output", which includes the filename. **This is ambiguity in the
  task text, not a model failure.** It flips on a coin.

### The quantisation axis — a negative result

Same box, same tasks, same gates. `glm-q6` (Q6_K, 27.2 GB resident) versus
`glm-q4` (Q4_K_M, 21.2 GB resident).

| | strict | guided |
|---|---|---|
| **glm-q4** | 5/10 | **8/10** |
| **glm-q6** | 4/10 | 5/10 |

**Q6 scored worse than Q4 on both briefs.** That is the opposite of the
expected direction and it should not be over-read.

**What can honestly be said:**

- Going Q4 → Q6 did **not** improve the model's ability to author a
  verification gate. Whatever limits it at 5–8/10, quantisation damage in that
  range is not the binding constraint.
- The largest single effect observed today is the **brief** (+3 on q4), not the
  quant (−1 strict, −3 guided).

**What cannot be said:** that Q6 is *worse*. With n=10 a difference of one or
two points is well inside noise, and no repeat runs were done. The q4 strict
score reproduced exactly across two boxes, which is encouraging for the
instrument, but a single reproduction is not an error bar.

**The honest shape:** one clean positive (brief, +3, predicted in advance), one
clean negative (quantisation, no improvement), and an n far too small to rank
anything separated by one point. Next run needs repeats, not more conditions.

### What this supports, and what it does not

**Supports:** instruction quality moves a small model's ability to author a
verification gate by 60% relative, with the model held fixed. Structure is a
larger lever than it is usually given credit for.

**Does not support:** "better prompts fix small models." One of the three added
sentences caused a regression. Guidance is a lever with a sign, not a
monotone improvement, and it must itself be measured.

**Still true:** even at 8/10, one in five gates a 30B writes would let a wrong
answer through or reject a right one. Authoring the gate stays with the
operator. The model does the work.

---

## 2026-07-30 — GLM-4.7-Flash

**Model:** `GLM-4.7-Flash-Uncensored-HauhauCS-Balanced` Q4_K_M GGUF
**Serving:** llama.cpp CUDA, ctx 32768, `--n-gpu-layers 999`
**Hardware:** vast.ai, 2× RTX 4060 Ti (31 GB VRAM total), ~19.5 GB resident
**Harness:** pi 0.83.0, one fresh process per point, no law appended

| Gym | Score | What it measures |
|---|---|---|
| `smoke-3` | **3 / 3** | can it call tools and write a correct artifact |
| `analyst-12` | **10 / 12** | multi-step joins across STIX / KEV / EPSS |
| `flash-100-core` | **13 / 23** | the 2026-07-29 gym, re-run under real checks |
| `gate-test` | **5 / 10** | can it *author* a check (the seat question) |

### gate-test, broken out

| Gate | Score | |
|---|---|---|
| A — real | 9 / 10 | fails when the artifact is absent |
| B — correct | 5 / 10 | passes the known-good artifact |
| C — discerning | 10 / 10 | rejects a wrong-but-present artifact |
| **all three** | **5 / 10** | |

Gate B is the binding constraint. Computing ground truth by a path independent
of the artifact is harder than doing the task.

Failure taxonomy: 2× assumed `jq` was installed (it was not), 1× iterated the
KEV dict instead of `data["vulnerabilities"]`, 1× emitted invalid bash, 1×
stricter than the artifact and arguably right.

It never once wrote a lazy existence-test. 10/10 on gate C.

### The single most useful artifact

`analyst-12` point 12 asked for every `x_mitre_shortname`, sorted.

```
produced:  ["collection", "command and control", "credential access", ...]
truth:     ["collection", "command-and-control", "credential-access", ...]
```

It prettified the data — turned literal field values into human-readable
spacing. A human reviewer skims that and passes it. The check did not.

### Grounding

`flash-100-core` point 13 asked for the STIX object count and **did not name the
file**. Two candidate files exist in that directory. The model read the wrong
one, wrote `25843` against a truth of `25843`, and reported "Done."

**This is weaker than it first appears, and the retraction matters more than
the anecdote.**

The two candidate files differ in exactly one respect. Of ten plausible
questions about that bundle, only *one* — the object count — gives a different
answer between STIX 2.0 and 2.1:

| question | 2.0 | 2.1 |
|---|---|---|
| object count | 25843 | **25843** |
| attack-pattern · malware · intrusion-set · relationship | 858 · 729 · 189 · 21025 | identical |
| tactic · tool · course-of-action · deprecated · sub-technique | 15 · 95 · 268 · 289 · 493 | identical |

So reading the wrong file was almost always harmless here. The one case where
it mattered is the one case that was observed. That is a coincidence worth
naming rather than a law worth citing.

The aggregate correlation is also thin: 5/12 of `analyst-12` points name an
absolute path versus 6/23 of `flash-100-core`. Directionally consistent with
the scores; far from proof.

**Status: one observation. No controlled test was possible on this file pair,
because the decoy does not discriminate. A real grounding experiment needs a
corpus where ambiguous references produce genuinely different answers.**

---

## 2026-07-30 box #3 — the coding gyms (RTX 6000 Ada, 48 GB, ctx 65536)

### code-10 — glm-q4 — **9/10**

Pre-registered before the run: **4–6/10**, with the corpus half named as "the
wall". Both numbers were wrong, and the reasoning was wrong in a way worth
keeping.

| # | point | verdict |
|---|---|---|
| 1 | dedupe-order | PASS |
| 2 | merge-intervals | PASS |
| 3 | flatten-dict | PASS |
| 4 | retry-backoff | PASS |
| 5 | kev-count-lib | PASS |
| 6 | kev-to-csv | PASS |
| 7 | stix-histogram-lib | PASS |
| 8 | stix-resolve-refs | PASS |
| 9 | cli-tool | **FAIL** |
| 10 | spec-linter | PASS |

**The corpus half went 4/4** — including point 8, resolving `source_ref` and
`target_ref` across a 25 843-object STIX bundle to list every malware and tool
an intrusion-set uses.

### Why the prediction was wrong about the mechanism

`analyst-12` scored 10/12 but died where it died because it was asked for a
**number** and could answer from weights. `code-10` asks for a **program that
computes the number** — and that turns out to be *easier*, because the artifact
is executable and a model cannot bluff an exit code. Being forced to write the
computation is itself a grounding mechanism.

That inverts the intuition this repo was built on. Harder-looking work was
more reliable, because it was less bluffable.

### The one failure was environmental, not cognitive

Point 9 wanted a bash script printing two counts with an exit-code contract.
The model:

- got the exit-code contract **right** (rc=2, usage on stderr)
- reached for `jq`, which is not installed on this box — exit 127
- assumed KEV was a top-level list; entries live under `"vulnerabilities"`

Both errors are facts about the machine, not gaps in ability — and both are
exactly the two facts the `guided` brief supplied in the earlier gate-test
experiment. This is an independent replication of that result, arrived at from
the opposite direction.

### The law was broken the whole time

All of the above was scored under a `SEAT.md` that told the model to verify
its work with `probe verify` / `probe sanity` / `probe doctor` at
`/home/michael/probe/probe` — gone since the merge into `sett`. **Every gym in
this repo's history ran under a law naming a tool that exits 127.**

9/10 is therefore a floor, not a ceiling: it is the score with the
self-verification path severed.

### Three defects found, two of them mine

| defect | whose | caught by |
|---|---|---|
| `smoke-3` p3 ground truth over a deleted dir — check **inverted** | mine | `gate-c.sh` |
| `SEAT.md` naming a dead tool | mine | reading it to edit it |
| `code-sett-8` p2 asserting against a live append-only file | mine | diagnosing a failure |
| p2: counted every line instead of grouping by id, guessed columns without reading the file | model's | the gym |

The gym's most valuable output today was not a score. It was a list of bugs in
the operator's own instructions.

### The law A/B — no effect detected, and why that is the useful answer

Question: does repairing `SEAT.md` change what the model produces? Arm A ran
the bare law preserved at HEAD; arm B the repaired one. Same model, same box,
same spec, n=2 per arm.

```
id  arm A     arm B     bucket
1   2/2       1/2       NOISY
2   0/2       1/2       NOISY
3   2/2       2/2       SOLID
4   2/2       2/2       SOLID
5   2/2       2/2       SOLID
6   1/2       2/2       NOISY
7   1/2       1/2       NOISY
8   2/2       2/2       SOLID

arm A: [6, 6]  mean 6.00     arm B: [7, 6]  mean 6.50
SOLID 4   DEAD 0   NOISY 4   SIGNAL 0
```

**Zero points differ stably between arms. Four of eight flip inside an arm.**

The pre-registered prediction was +1 to +2 for the repaired law. That was
wrong, but the interesting part is that the *first* pairing came back 6 vs 4 —
which, reported alone, reads as a clean demonstration that the repaired law
made things worse. The second pairing came back 6 vs 7, which reads as the
opposite. Same law, same model, same box, forty minutes apart.

**A single run of this gym supports whichever conclusion the operator was
hoping for.** That makes it worse than no gym, because it produces confident
numbers instead of visible ignorance.

This is the third time this repo has been saved by refusing to believe one
run — after the flash-100 "100/100" that meant only that files appeared, and
after the q6-beats-q4 expectation that came back negative.

### `sett ab` and the buckets

`sett ab <spec> <n> <lawA> <lawB>` runs the gym n times per arm and records
one row per point per run, so the analysis can be per-point rather than
per-total. Totals hide the thing that matters: a gym where every point is a
coin flip and a gym where six are solid and two are broken print the same
number and mean opposite things.

Every point lands in one of four buckets:

| bucket | meaning | what it is worth |
|---|---|---|
| SOLID | passes in every run of both arms | measures nothing; costs rental time |
| DEAD | fails in every run of both arms | measures nothing, or is broken |
| NOISY | flips within an arm | can support no claim at all |
| SIGNAL | stable within each arm, differs across | the only rows that mean anything |

When SIGNAL is empty the tool refuses to print a verdict. It says how many
points are NOISY instead, because that number — not the totals — is what
tells you how many runs the question actually needed.

### The night run — n=3 on both gyms, answer key out of reach

`sett leak` on the whole batch: **clean.** No run read its own spec.

#### code-10 — glm-q4 — runs **8, 8, 9** — mean **8.33**

| id | point | pass/3 | |
|---|---|---|---|
| 1 | dedupe-order | 3/3 | SOLID |
| 2 | merge-intervals | 3/3 | SOLID |
| 3 | flatten-dict | 3/3 | SOLID |
| 4 | retry-backoff | 3/3 | SOLID |
| 5 | kev-count-lib | 3/3 | SOLID |
| 6 | kev-to-csv | 3/3 | SOLID |
| 7 | stix-histogram-lib | 3/3 | SOLID |
| 8 | stix-resolve-refs | 2/3 | NOISY |
| 9 | cli-tool | 1/3 | NOISY |
| 10 | spec-linter | 1/3 | NOISY |

**The 9/10 published earlier today was the best of three, not the typical
one.** The honest figure is 8–9, mean 8.33. That is a 0.67-point
overstatement drawn from a single sample — small, and precisely the error
this repo exists to prevent. It is corrected here rather than quietly
restated.

What survives is larger than what was retracted: **points 1–7 pass 3/3.**
Seven tasks reliably solved, three of them computing over real corpora on
disk — 1 655 CISA KEV entries and a 25 843-object STIX bundle. That is a
capability, not an afternoon.

The frontier is honest and narrow: multi-hop relationship resolution passes
most of the time (2/3); the `jq` point still fails two runs in three even
with the missing binary named in the law, so that fact alone was not the
cure; and the spec-linter had been passing when it could read its own spec.

#### code-sett-8 — leak closed — runs **5, 6, 7** — mean **6.00**

| 1 | 2/3 | 2 | **0/3** | 3 | 2/3 | 4 | **3/3** |
|---|---|---|---|---|---|---|---|
| 5 | 3/3 | 6 | 3/3 | 7 | 2/3 | 8 | 3/3 |

**Point 4 moved 0/3 → 3/3.** The only change was the leak fix: the `do:`
stopped saying "reads a SETT .probe spec" and started naming the exact frozen
file. On that point ambiguity was not adding noise, it *was* the failure.

**Point 2 scored 0/3 in every configuration tried.** Its `do:` never stated
the column layout that point 1's states outright, so the model alternated
between a correct algorithm with wrong column indices and correct indices
with no grouping. Fixed after the box came down — stated, re-gated A/B/C
clean, and **not yet re-run.** It is an untested fix and is labelled as one.

### What the day established

| claim | verdict |
|---|---|
| a 30B writes working code against real corpora | **yes** — 7 points 3/3 at n=3 |
| ...including multi-hop graph traversal | mostly — 2/3 |
| the 9/10 headline | **overstated** — 8–9, mean 8.33 |
| the repaired law helps | **not established** — no point differed stably |
| de-ambiguation reduces noise | **yes** — NOISY 4→2; one point 0/3→3/3 |
| the model exploited the answer key | **no** — but it could have, and now cannot |

Four of six rows describe defects in the instructions, not the model.

### Caveat on the historical gyms

`sett lint` finds unnamed inputs in **analyst-12 (7 points)** and
**flash-100-core (12 points)**: the `do:` describes the corpus in prose — "the
KEV catalog" — without naming a path, while the check reads a specific file.

Every point runs as a fresh `pi` process seeing only its own `do:` line. So on
those points the model was not handed its input; **it went hunting the
filesystem for it.** analyst-12's 10/12 and flash-100-core's audited 23/23
were achieved under that condition and partly measure the model's willingness
to search, not only its ability to compute.

**Those specs are deliberately not being fixed.** Editing them would silently
invalidate every number already published against them, and rewriting the
ruler after the measurement is the exact failure this document exists to
prevent. They stand as the historical record they are, with this caveat
attached. New gyms name their inputs.

### debug-7 — the repair gym (built, gated, NOT YET RUN)

Every other gym asks the model to write fresh code. `debug-7` hands it broken
code and asks for a fix, which is most of what a coding assistant actually
does and which nothing here measured.

Every broken file is real: seven artifacts GLM-4.7-Flash wrote on this box on
2026-07-30, each of which failed its own gym point. Frozen under
`fixtures/broken/`, confirmed still broken in the specific way each point
describes:

| point | the real bug |
|---|---|
| 1 | annotated `path: Path`, called `path.read_text()` on a str |
| 2 | read `parts[0]`/`parts[1]` as id/verdict — they are timestamp/id — returns all zeros |
| 3 | correct docstring, counted every line instead of grouping by id |
| 4 | point-matching regex matches nothing, returns 0.0 |
| 5 | found 4 of 12 checks |
| 6 | returned `""` for an empty list instead of the header |
| 7 | called `jq` (not installed) and indexed the JSON as a list |

Graded by the **same checks** the original points used, so a score here is
directly comparable to the score the broken file earned.

**Gate D, new for this gym type.** A repair gym has a failure mode the other
gates cannot see: if the broken input would itself pass, the point is solvable
by copying the input, and the gym measures `cp`. `sett gate <spec> --broken`
plants each broken file as the artifact and demands the check fail.

Gates: **A 7/7 · B 7/7 · C 7/7 · D 0/7 broken inputs pass · lint 0.**
Gate D was itself negative-controlled: planting a correct implementation where
a broken one belongs makes it exit 1.

**It has not been run.** There is no score here and will not be until a box
runs it.

### Correction: flash-100-core is 22/23, not 23/23

The published figure was gate A only — every check fails when the artifact is
absent. Gate C did not exist when that audit ran. Applied now, `flash-100-core`
point 87 is a genuine fake:

```
## 87 sha256-of-84
do:    Write the sha256sum of $OUT/84-hello.txt to $OUT/87.txt
check: grep -qF "$(sha256sum "$OUT/84-hello.txt" | cut -d' ' -f1)" "$OUT/87.txt"
```

When `84-hello.txt` is absent, `sha256sum` prints nothing, the grep pattern
becomes the empty string, and **`grep -qF ""` matches any non-empty file.**
The point passes on arbitrary garbage. Reproduced directly:

```console
$ echo "anything at all" > 87.txt          # 84-hello.txt does not exist
$ grep -qF "$(sha256sum 84-hello.txt 2>/dev/null | cut -d' ' -f1)" 87.txt && echo PASSES
PASSES
```

In a sequential run `84-hello.txt` usually exists, so this rarely fired. But it
means **point 87 silently passes whenever point 84 failed** — a scoring
dependency nobody declared.

This is the fourth instance of one bug family found today:

| where | expected value derived from | became |
|---|---|---|
| `smoke-3` p3 | `find` over a deleted directory | `0` — check inverted |
| `SEAT.md` | a tool path removed in a merge | exit 127 |
| `code-sett-8` p2 | a live append-only `state.tsv` | drifts on next run |
| `flash-100-core` p87 | `sha256sum` of a possibly-absent file | `""` — matches anything |

**Not fixed.** flash-100-core is a historical record with published scores;
editing it would invalidate them. Recorded here and accepted in
`selftest.accept` with this reason, so every future selftest prints it rather
than rediscovering it.

## Verdict so far

A 30B-class local model does the work and cannot certify the work.
10/12 on real analyst joins; 5/10 on authoring the gates that would grade them.

Deciding stays with the operator. Certifying stays with the program.
The middle row rents for pennies.

## Reproducing

```sh
sett gate <spec>            # gate A: prove the checks fail with no artifact
sett gate <spec> --wrong    # gate C: prove they fail on a WRONG artifact
sett rot                    # prove nothing the repo asserts has moved
sett gym <spec> --model <provider/model>
sett check <spec>           # re-check every artifact, read-only, no model
sett ab <spec> <n> <A> <B>  # n runs per arm before believing a difference
```

`sett gate` was run on every spec before any model saw it:
`smoke-3` 3/3 real, `analyst-12` 12/12 real, `flash-100-core` 23/23 real
**on gate A**. Gate C, written later, puts flash-100-core at **22/23** — see
the correction below.
