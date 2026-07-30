# RESULTS

One row per model per gym. A point counts only if its check exited 0.
No partial credit. No SKIP.

---

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
one, wrote `25842` against a truth of `25843`, and reported "Done."

**This is weaker than it first appears, and the retraction matters more than
the anecdote.**

The two candidate files differ in exactly one respect. Of ten plausible
questions about that bundle, only *one* — the object count — gives a different
answer between STIX 2.0 and 2.1:

| question | 2.0 | 2.1 |
|---|---|---|
| object count | 25842 | **25843** |
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

## Verdict so far

A 30B-class local model does the work and cannot certify the work.
10/12 on real analyst joins; 5/10 on authoring the gates that would grade them.

Deciding stays with the operator. Certifying stays with the program.
The middle row rents for pennies.

## Reproducing

```sh
probe sanity <spec>    # prove the checks are real before trusting the score
probe run <spec> --model <provider/model>
probe verify <spec>    # re-check every artifact, read-only, no model
```

`probe sanity` was run on every spec before any model saw it:
`smoke-3` 3/3 real, `analyst-12` 12/12 real, `flash-100-core` 23/23 real.
