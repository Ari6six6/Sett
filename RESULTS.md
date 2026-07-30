# RESULTS

One row per model per gym. A point counts only if its check exited 0.
No partial credit. No SKIP.

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

One documented instance, not yet a law. The aggregate correlation is weaker
than it looks: 5/12 of `analyst-12` points name an absolute path versus 6/23 of
`flash-100-core`. Directionally consistent with the scores, far from proof.
**Open question for the next run: hold the model fixed and vary only whether
the instruction names the path.**

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
