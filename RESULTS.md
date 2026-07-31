# RESULTS

One row per model per gym. A point counts only if its check exited 0.
No partial credit. No SKIP.

The live version of the table below is `sett score`, computed from
`runs/*/state.tsv` rather than typed by hand. This file is the written record:
the analysis, the confounds, and the caveats a table cannot carry.

---

## The standing table

Every gym, flown three times each on one box in one afternoon.

**Model:** GLM-4.7-Flash Q4_K_M (HauhauCS Balanced) · **Box:** 1× A100-PCIE
40 GB · **ctx:** 65536 · **law:** none (bare seat) · 2026-07-31

| gym | what it asks for | reps | mean | shape |
|---|---|---|---|---|
| `code-10` | ten coding tasks, three over real corpora | 9, 7, 9 | **8.33/10** | 7 SOLID · 2 NOISY · 1 DEAD |
| `stix-graph-12` | multi-hop traversal of a 25 843-object STIX bundle | 10, 9, 8 | **9.00/12** | 5 SOLID · 7 NOISY · 0 DEAD |
| `code-sett-8` | eight utilities this repo actually wanted | 8, 7, 7 | **7.33/8** | 6 SOLID · 2 NOISY · 0 DEAD |
| `debug-7` | repair seven genuinely broken files | 5, 5, 3 | **4.33/7** | 2 SOLID · 5 NOISY · 0 DEAD |
| `smoke-3` | wiring check | 3 | 3/3 | — |

Read the `shape` column, not the mean. `code-sett-8` at 7.33/8 and `debug-7` at
4.33/7 are 92% and 62%, and the second number is the interesting one:
**authoring 83%, repairing 62%**, same model, same box, same hour, same
grading checks.

The one DEAD point is `code-10` p9, and it is dead for a stated reason — see
below. Nothing else in 37 points across four gyms failed every time.

`sett score` prints the live version of this table.

---

## 2026-07-31 box #4 — the six predictions

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

**10, 9, 8 — mean 9.00, spread 8–10.** Multi-hop relationship resolution over
a 25 843-object STIX bundle: resolving `source_ref` and `target_ref` against an
index the model must build before it can answer anything.

**Prediction 5 confirmed, and it is the largest single fix of the day.** A gym
that could not run at all now averages 9/12.

**No point is DEAD.** Every one of the twelve passed at least once, so nothing
here is beyond the model. But **7 of 12 are NOISY** — they flip between reps:

| bucket | points |
|---|---|
| SOLID 3/3 | 1, 3, 5, 7, 8 |
| NOISY | 2, 4, 6, 9, 10, 11, 12 |
| DEAD | none |

That is the honest shape and it is not a flattering one. A gym where more than
half the points flip cannot rank anything at n=3, and the mean of 9.00 carries
a spread of two points. The right next move is more reps, not more gyms —
`sett runs stix-graph-12 10` would say whether 9.00 is a level or a coin.

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

---

## Note on the portability refactor (2026-07-31, after the flight)

Every live spec was rewritten to say `$SETT/...` and `$CORPUS/...` instead of
`/home/michael/...`. That moves each spec's `spec@` hash, so `sett score` marks
today's scores as earned against a gym text that no longer exists.

**The flag is correct in general and wrong in this instance**, and that claim is
settled mechanically rather than asserted. `sett prompts <spec> --checks`
renders the exact text a model receives after expansion; captured before and
after the rewrite, all five live specs diff **byte-identical**. The file
changed; the prompt did not; the numbers above still mean what they say.

Proof that `$CORPUS` is load-bearing rather than decorative, by relocating it:

```
corpus at a different path   sett check code-10 --out reference/  ->  10/10 PASS
corpus pointed at nothing    sett check code-10 --out reference/  ->   5/10 PASS
```

Exactly the five data points fail. A variable that changes nothing when you
break it was never wired up.

**Two defects the refactor introduced, both caught and fixed:**

- Binding `SETT=` in the environment was not enough. Most checks embed their
  path inside a single-quoted python one-liner, where bash expands nothing, so
  the check received the literal four characters `$SETT`. Gate B found it
  immediately: every reference implementation stopped passing.
- `sett rot` went **blind**. It greps for `/home/...`, the specs no longer say
  that, and its coverage fell from 31 asserted paths to 13 while still printing
  `clean`. An audit that silently narrows its own scope is worse than no audit.
  Rot now expands the variables first; a deliberately planted dead `$CORPUS`
  path is caught through them, and reported fully resolved.

---

## What the model DID, not just what it scored (2026-07-31)

`sett behave` reads `pi`'s own transcripts — every tool call, every thinking
block — across 257 point-runs. A score says whether a point passed. This says
how, and the two do not always agree.

| gym | read-first | verify | one-shot | median steps |
|---|---|---|---|---|
| `debug-7` | **95%** | 71% | 24% | 10 |
| `code-sett-8` | 28% | **83%** | 7% | 8 |
| `stix-graph-12` | 81% | 28% | **72%** | **16** |
| `code-10` | 6% | 59% | 13% | 8 |

**`debug-7` is the only gym where the model reads its input almost every time**
— 20 of 21 runs. That is the same gym that produced the only two timeouts of
the day. Repair forces a read before a write, and the reading is what costs the
clock. The 62% score and the `pi exit 124` errors are the same fact seen twice.

**`stix-graph-12` is the opposite shape**: the most steps of any gym (median
16), yet 72% one-shot and only 28% verifying. It spends its budget hunting
through a 53 MB bundle, then writes once and does not look back — and still
averages 9/12. High effort, low self-checking, decent score.

None of this is visible in a pass count, and none of it changes one. It is
recorded because behaviour is the thing that predicts where the next failure
comes from, and a ledger that only stores verdicts throws it away.

---

## The apparatus, turned on the assistant driving it (2026-07-31)

`sett behave` grades the small model in the gym. It had never been pointed at
the *other* mouth — the frontier model writing the specs, the checks, and the
decisions about what counts as done, which is the row this repo says a model
must never be trusted with.

Claude Code writes the same kind of record pi does, so `sett behave --session`
asks it the same question.

| | model being graded | assistant doing the grading |
|---|---|---|
| checked its own work | **67%** | **68%** |

**Nearly the same rate — and the comparison must be read carefully.** These are
not the same measurement: the gym figure counts artifact re-reads per point,
the session figure counts verification commands within six tool calls of a file
change. Different definitions over different populations doing different work,
both written by the same hand. The near-match is striking and may be
coincidence of definition; it is **not** evidence that the two models are
equally capable, which is what the gym scores measure and where they differ.

What it does support is narrower and still worth having: the mouth doing the
checking was itself running at 68%. The assistant
also wrote 125 times and read 29 — a read:write ratio of **0.23**, while
working under a law whose first rule is *answer from disk, not from your
weights.*

### The part that is not a coincidence

`rot.ignore` names exactly two paths as dead on purpose:

```
/home/michael/probe/probe
/home/michael/probe/specs
```

Those are the paths whose deletion produced the founding inversion — the check
that stopped screaming and started smiling, where `4` began FAILING and `0`
began PASSING. They are also the **top two entries** in the list of file
changes that were never verified afterwards.

**The region of work checked least is the region that produced the worst defect
in the repo.**

**Confound, and it matters:** `probe/` is the earliest work in this transcript,
from before most of these instruments existed. Low verification there may be
because there was nothing to verify with, not because of carelessness. That
reading does not weaken the conclusion — it is the conclusion. The defect
survived because no instrument was watching, and it was found the moment one
was.

### Why this is recorded rather than hidden

Every defect on this repo's confession list was found, and the numbers in this
file are unchanged by any of it. The point is *how* they were found: roughly
half by an instrument firing — gate B when the reference implementations
stopped passing, the asserted-path count when it fell from 31 to 13 — and half
by reading the data.

Vigilance did not scale across an eight-hour session. The instruments did.
That is the whole argument for building them, and it now applies to both mouths
rather than only the cheap one.

---

## Defect 9: the compounding claim did not hold (2026-07-31)

The README carried this until today's rewrite:

> *"`gate-c.sh` is built on `points()` and `checks()` — two of the eight
> utilities `code-sett-8` asked the model to write. The gym's output audits the
> next gym. That is the only kind of compounding this repo is trying to have."*

That was the repository's central claim about **compounding** — that the work
feeds itself, model output becoming the next instrument. Checked, on challenge:

- `gate-c.sh` depends on `reference/code-sett-8-reference`, which is the
  hand-written **reference implementation** — gate B's answer key, authored by
  the operator, not produced by a gym run.
- No file in that directory is byte-identical to any archived model artifact.
- Style is decisive: **24 of 24** GLM artifacts from today's runs carry
  docstrings; **0 of 8** reference files do. The reference has no docstrings,
  no type hints, no imports. It is not the same hand.

The claim is therefore **unsupported**, and the evidence points against it.

It is not fully disproven — provenance was never recorded, which is the actual
root cause. A claim about where code came from needs the same treatment as a
score: recorded at the time by a program, not remembered afterwards. `runs.tsv`
now does this for scores. Nothing does it for reference implementations.

**The claim was removed from the README in the same day's restructure, by
accident.** It did not survive an editorial cut. That is luck, not an audit,
and the two are easy to confuse in hindsight — which is why it is written down
here rather than quietly left deleted.

Found because the operator asked a hostile question about who writes the gyms.
No gate covers prose, and prose is where the flattering claims live.

---

## SEALED 2026-07-31 — written BEFORE box #5 was provisioned

Recorded first, on the operator's challenge, so the record shows they were not
written after seeing the outcome.

### `index-6` — the lab's missing tool, never run

1. **Points 1, 2 and 6 land SOLID (3/3).** Type census, external-id lookup and
   the CLI wrapper are single-table queries with the contract fully stated.
2. **Point 5 is the one that flips.** The unmitigated join needs a correlated
   `NOT IN` over a subquery of `relationships` while joined to `kill_chain`.
   It is the only point requiring two joins and a negation.
3. **Gym mean ≥ 4.5 / 6.**

### `stix-graph-12` at n=10 — killing the noise on the flagship number

4. **The mean lands within 8.2–9.8**, the 95% band implied by the n=3 data.
   Outside that band means the n=3 estimate was *biased*, not merely noisy —
   a finding about the instrument, not the model.
5. **At least 5 of the 7 currently-NOISY points still read NOISY.** A point
   whose true rate is ~0.67 has a 1.8% chance of reading all-pass-or-all-fail
   at n=10, so genuine mid-rate points cannot resolve. If most of them *do*
   resolve, the n=3 flapping was never sampling noise — it was structural, and
   that would be the most important thing this run could say.

Failure of 4 or 5 is more interesting than success. Both are about whether the
instrument reads true, not about whether the model is good.

---

## Box #5 — `index-6`, and defect 10 found by its own failure

`index-6` is the gym built from the lab's own dated scar: a sqlite wrapper the
SCARS.md entry asked for on 2026-07-28 and nobody wrote. First flight, n=3.

**4, 5, 3 out of 6 — mean 4.00.**

| bucket | points |
|---|---|
| SOLID 3/3 | 2 db-external-id · 3 db-neighbors · 4 db-phase |
| NOISY | 1 db-types (2/3) · 6 db-cli (1/3) |
| DEAD 0/3 | **5 db-unmitigated** |

### The sealed prediction was mostly wrong

Recorded at 16:59:33, commit `e5675b7`, before the box existed:

| claim | outcome |
|---|---|
| points 1, 2, 6 land SOLID | **wrong** — only 2 did; 1 is 2/3 and 6 is 1/3 |
| point 5 is the one that flips | **half right** — it is the failure, but it never passed once. Predicting NOISY and getting DEAD is not a hit |
| gym mean ≥ 4.5/6 | **wrong** — 4.00 |

One of three. The instinct about *which* point was hardest was right and the
reasoning was right — two joins and a negation — but calling the bucket wrong
matters, because DEAD and NOISY have different causes and different fixes.

### Why point 5 died — and it is not the model's fault alone

The artifact does two things wrong. It writes `FROM attack-pattern ap`, turning
a *type value* into a table name; and it calls `cursor.fetchall()` twice, so the
second call returns empty and the function yields 0 rows where 26 are expected.
The first is a real model error.

But it also guessed `kc.object_ref` for the join column. **Point 4's `do:`
names the kill_chain columns. Point 5's did not.** That is a coin flip the
operator built, in a gym written the same afternoon, in a repo whose whole
argument is that such coin flips read as model failures.

### Defect 10 — `sett lint` was a blind audit

That asymmetry is *precisely* lint's second category, "formats a sibling
explains but this point does not". Lint reported **0 defects** on `index-6`.

The category was implemented as a hardcoded dictionary of two formats —
`state.tsv` and `.probe` — the two this repo grew up on. It had never heard of
a `kill_chain` table, so it narrowed silently to what it was born knowing and
kept printing the reassuring word. Same disease as `rot` going blind when the
specs became portable, found the same way: by something failing that it should
have caught first.

The check is now generic: if any point enumerates the columns of a named table
and a sibling references that table without them, it fires. On `index-6` it
immediately named point 5 twice — for `kill_chain` **and** for `relationships`
— and produced no new findings on the six other specs.

`index-6` p5 now states all three schemas; lint is 0; gates A, B and C still
hold at 6/6. The spec text changed, so the 4/5/3 above is the score of a gym
text that no longer exists, and `sett score` will mark it `(!)`. That is
correct: the next run measures a different question.

**Prediction, sealed before that run happens: point 5 moves off 0/3.**

---

## Defect 11 — an empty gate read as a passing gate

Prompted by defect 10, every instrument was swept for the same disease:
hardcoded knowledge that silently narrows. One live dependency turned up.

`gate-c.sh` parses specs using `reference/code-sett-8-reference` — a real
dependency, not a comment. Hidden on purpose, gate C printed:

```
gate C: 0/0 checks reject a plausible impostor, 0 FAKE
```

and **exited 0**. "0 FAKE" reads as success.

Worse, `selftest` judged that **clean on every spec**, because its rule is
`passed == total` and `0 == 0` satisfies it. Gate C — the gate that caught the
one historical fake in `flash-100-core` — verified *nothing* on seven specs
while the table showed no complaint.

The run did fail, but by luck: gate B independently noticed the same directory
was missing, because the parser happens to live under `reference/`. **Had that
parser lived anywhere else, selftest would have printed PASS while gate C was
blind.** A safety net that catches a fault through an unrelated instrument is
not a safety net, it is a coincidence.

Fixed at both ends, and negative-controlled in both directions:

- `gate-c.sh` now refuses to report a score when it parsed 0 points: it prints
  `BROKEN`, names the dependency, and **exits 2** (verified: was 0, now 2).
- `selftest` treats `0/0` as a failure explicitly, never as clean, and it is
  not eligible for `selftest.accept`.

With the parser hidden, selftest now flags gate C on every spec. With it
restored, everything returns to green and exit 0. Both directions checked,
because a detector you have never seen fire is not a detector.

**Three instruments have now had this defect** — `rot` went blind when specs
became portable, `lint` was hardcoded to two formats it grew up with, and gate
C reported success on an empty run. The pattern is the finding: *an instrument
tends to narrow to the world that existed when it was written, and it keeps
printing the same reassuring word while it does.*

---

## Sealed prediction 4 is not testable, and I broke it myself

**Written at 18:10Z with six of ten reps in, before the final number.**

Prediction 4 said the `stix-graph-12` mean at n=10 would land in **8.2–9.8**,
the 95% band implied by the n=3 data, and that landing outside it would mean
the n=3 estimate was *biased rather than noisy* — a finding about the
instrument.

Through five reps it is running **10, 10, 11, 11, 11**. It is going to fail
high. But it cannot be read the way the prediction intended, because **the
conditions moved**:

| | box #4 (the n=3 baseline) | box #5 (this run) |
|---|---|---|
| GPU | A100-PCIE 40 GB | RTX PRO 6000 Blackwell 95 GB |
| context | 65 536 | 98 304 |
| model, quant, spec text | identical | identical |

The spec text really is identical — the portability refactor was proven
cosmetic by rendering both versions and diffing, so the prompt is byte for
byte what box #4 saw. But **context size is not a neutral variable for this
gym.** Every point traverses a 51 MB bundle through a `bash` tool, and a model
with half again as much room to hold what it read has a plausible causal path
to a better score. That is a mechanism, not merely noise.

So a mean above the band supports either reading — n=3 was biased low, *or*
the bigger box helps — and **this run cannot separate them.**

**That is my error, not the instrument's.** I sealed a prediction about
sampling error and then changed the hardware underneath it. It is the same
class of mistake as prediction 4 this morning, which aimed at a point that had
never failed: a prediction that cannot come out false is useless, and so is one
whose conditions I did not hold fixed. The repo has a word for the second and I
wrote it into the glossary this afternoon — **confound** — and then walked into
one anyway.

What the run still settles cleanly is **prediction 5**, which is about the
*shape* rather than the level: at least 5 of the 7 NOISY points should still
read NOISY, because a point whose true rate is mid-range cannot resolve at
n=10. That claim survives the box change, since it is about within-run
variance rather than the absolute score.

**The clean experiment was available and I did not run it:** ten reps on the
same box as the baseline. Recorded so the next person does not repeat it.

### Retiring the confound rather than confessing it

**Sealed at 18:12Z, before the isolating run.**

A confound stated and left standing is just a nicer way of publishing a number
you cannot defend. This box can separate the two variables directly: same
hardware, same weights file, same spec, **context dropped back to 65536** — the
only difference from the n=10 run above.

| outcome | reading |
|---|---|
| ctx-65536 here scores ~9 | context was the cause; the n=3 baseline was fine |
| ctx-65536 here scores ~10 | context is not the cause; **n=3 really did under-measure this gym** |

**My prediction: ~10.** Every point is a fresh process that reads the 51 MB
bundle through a `bash` tool in chunks; it never needed 98k of room to begin
with. If that holds, the honest reading of the n=10 result is that three reps
under-measured `stix-graph-12`, which is a finding about the *instrument* and
the one I said would be more interesting than success.

It does not fully isolate the GPU — an A100 and a Blackwell still differ — but
it removes the variable with an actual causal story attached to it.
