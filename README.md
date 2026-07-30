# SETT

> **The brain proposes. The captain disposes. The ledger makes faith obsolete.**

---

A sett is a badger's den. It is dug once and extended by generation after
generation, for decades. No badger has ever abandoned a sett because the
architecture was wrong.

**That is the whole rule.** This repository is extended. It is never restarted.

---

## What this is

An apparatus for not believing the model.

Fifteen repositories on this account built that apparatus and buried it inside
a harness. Same organ, fifteen names, never once the product:

| | | |
|---|---|---|
| `project_michael` | May | the four-header context package; the `commit_changes` gate |
| `Hermes` | Jul 5 | **Verification Gauntlet** — *"the doer doesn't grade its own homework"* |
| `MoR` | Jul 17 | **The Audit** — a falsification state entered *before* speaking |
| `KARL` | Jul 19 | structured handoffs; bounded reasoning |
| `MoRE` | Jul 20 | *"a turn that changed files but ran nothing is bounced once"* · *"provenance can no longer lag the evidence"* |
| `KM1` | Jul 20 | a night shift judged by **a benchmark it cannot game** |
| `KM2` | Jul 21 | the hash-chained ledger — *"the ledger makes faith obsolete"* |
| `KM` | Jul 28 | the DEMO law · *canary > `/v1/models` 200* |
| `karte/RULES.md` | Jul 28 | R2 different mouths · R5 shallow diary = REJECT · R11 ground-first |

Here it is the product.

## The division of labour

```
What is worth doing        →  the operator
How to do it               →  the model
Whether it was done right  →  a program
```

A model can do the middle row. It cannot do the top row, and it must never be
trusted with the bottom row. Every scar in this lineage is an instance of a
model being asked to do the top or the bottom row.

## The rule

**SETT contains no program.**

No installer. No framework. No agent loop. No harness. The runner already
exists, it is 437 lines of bash, and it is finished.

This repository holds only:

```
specs/      gyms. one bounded task, one artifact path, one machine check.
corpus/     manifests for the data the checks grip on.
RESULTS.md  model x gym x score.
```

If SETT ever acquires a `setup.sh`, it has become the sixteenth harness and the
loop has won.

## Why this and not a harness

The harness layer is free and improving without me — pi, Claude Code, and the
rest are better than anything I would raise. The model layer is commoditising.

**Verified task definitions in a specific domain are neither.** They need a
corpus, domain judgement, and a decision about what "correct" means. No lab
ships those for my domain. That is the scarce input, and it is the only layer
where my labour compounds.

## What a point looks like

```
## 11 stix-bytes
do:    Write only the byte size of /path/to/enterprise-attack-stix21.json to $OUT/11.txt
check: test "$(tr -d '[:space:]' < "$OUT/11.txt")" = "$(stat -c%s /path/to/enterprise-attack-stix21.json)"
```

Four fields. The operator writes `do` and `check`. The model never sees `check`
— a model that can read the gate can teach to it.

## Three laws for the checks

1. **The check is a program, not a model.** A program cannot be flattered.
2. **A check must fail when the artifact is absent.** Otherwise it is a fake gate.
3. **A check must fail when the artifact is wrong.** Otherwise it is an existence
   test, and an existence test is what let a hundred-point gym score 100/100
   while proving only that files appeared.
