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

**SETT never implements the agent loop.**

It calls `pi`. `sett do` is one `exec` of `pi` and nothing more. The day a
`while` loop appears around a model turn in `sett`, this has become the
sixteenth harness and the loop has won.

That is the only prohibition. Everything else may be built.

Fifteen repositories died of writing the agent loop — the free layer, the one
that improves without me. Nothing died of writing an instrument.

```
sett        the program. one file, ~530 lines of bash.
specs/      gyms. one bounded task, one artifact path, one machine check.
corpus/     manifests for the data the checks grip on.
RESULTS.md  model x gym x score.
SEAT.md     the law a task runs under.
```

## The verbs

```sh
# the body
sett birth "-p 32130 root@1.2.3.4 -L 8080:localhost:8080"   # rent, provision, wire
sett body                    # what is ACTUALLY served — the live endpoint, never a file
sett do "count the KEV ransomware entries"                  # one bounded task
sett kill                    # stop paying

# the ledger
sett gym analyst-12          # put a model through a gym
sett gate analyst-12         # are the checks real? mutation-test them first
sett check analyst-12        # re-verify every artifact, read-only, no model
sett score                   # the table
sett vault check gold        # prove nothing was lost
```

`sett body` reads the model from the live endpoint on every invocation. There
is no pin file to drift. A dead endpoint makes `sett do` exit 3 and say so —
it will not quietly fall back to a cloud model and let you think otherwise.

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
4. **A check must assert against something that cannot move.** Laws 2 and 3 both
   ask about the artifact. Neither asks whether the *ground* is still there.

## The fourth law was paid for

`smoke-3` point 3 computed its expected value with `find` over
`/home/michael/probe/specs`. That directory vanished when `probe` was merged
into `sett`. `find` on a missing directory returns nothing, so the expected
value silently became `0`.

The check did not break. It **inverted**: the model's correct answer, `4`,
began FAILING, and a garbage answer, `0`, began PASSING. It had been sitting
in the ledger as a PASS.

The same bug was in the law. `SEAT.md` told the model to verify its work with
`probe verify` at `/home/michael/probe/probe` — so every gym ever run had been
scored under instructions naming a tool that exits 127.

And a third costume: `code-sett-8` point 2 asserted `["pass"]==3` against
`runs/smoke-3/state.tsv`, an append-only file that the next run would have
changed underneath it.

One bug, three costumes: **a check whose expected value is computed from
something that can move.** Hence `fixtures/`, and hence:

## The instruments

| tool | question it asks | what it caught |
|---|---|---|
| `sett gate` | is the check fake — does it pass with **no** artifact? | four fake checks at authoring time |
| `sett gate --broken` | repair gyms: does the **broken input** pass? | (new — gates `debug-7`) |
| `gate-c.sh` | does it pass on a **wrong-but-present** artifact? | `smoke-3` point 3 |
| `rot.sh` | does every path the repo **asserts** still exist? | the dead law pointer |
| `ab.sh` | is this difference **real**, or is it one run's luck? | a 6/8-vs-4/8 "result" that was noise |

`gate-c.sh` is built on `points()` and `checks()` — two of the eight utilities
`code-sett-8` asked the model to write. The gym's output audits the next gym.
That is the only kind of compounding this repo is trying to have.
