# SETT

> **The brain proposes. The captain disposes. The ledger makes faith obsolete.**

Rent a GPU. Seat a local model. Make it prove every claim it makes — to a
program, not to you.

```console
$ sett birth "-p <port> root@<box-ip> -L 8080:localhost:8080" --model glm-q4
$ sett gym code-10
1     dedupe-order                 PASS
2     kev-ransomware-count         PASS
...
run: 9 PASS  1 FAIL  0 ERROR  (0 already passing, 10 points)

$ sett score
spec             score   reps       model                spec@    when
code-10          9/10    9,7,9      glm-4.7-flash        182cc6   2026-07-31 13:27
code-sett-8      7/8     8,7,7      glm-4.7-flash        4f3a2a   2026-07-31 13:10
debug-7          3/7     5,5,3      glm-4.7-flash        4fce52   2026-07-31 14:07
```

No transcript. No vibe. No "looks good to me." Every rep, the model that earned
them, and the hash of the exact task text they were earned against.

---

## What it actually is

An apparatus for **not believing the model** — including when the model is
right, which is the harder half.

```
What is worth doing        →  the operator
How to do it               →  the model
Whether it was done right  →  a program
```

A model can do the middle row. It cannot do the top row, and it must never be
trusted with the bottom row. Fifteen abandoned repositories on this account are
each an instance of a model being handed the top or the bottom row.

## The one rule

**SETT never implements the agent loop.**

`sett do` is one `exec` of `pi` and nothing more:

```bash
cmd_do() {
  local m; m="$(require_body)"
  echo "seat: km-box/$m   law: $SEAT" >&2
  exec pi -p "$*" --model "km-box/$m" --append-system-prompt "$SEAT"
}
```

The day a `while` loop appears around a model turn in `sett`, this has become
the sixteenth harness and the badger goes back in the ground.

That is the only prohibition. The harness layer is free and improving without
me — pi, Claude Code and the rest are better than anything I would raise. The
model layer is commoditising. **Verified task definitions over a real corpus
are neither**, and that is the only layer where my labour compounds.

---

## Quickstart

```sh
git clone https://github.com/Ari6six6/Sett && cd Sett
ln -s "$PWD/sett" ~/.local/bin/sett     # bash + coreutils + python3, nothing else

corpus/fetch.sh                          # the three public datasets the checks grip on
sett rot                                 # every path this repo asserts — do you have it?
sett selftest                            # are the gates real? 85s, no GPU, no model
```

Specs name `$SETT/...` and `$CORPUS/...`, never one operator's home directory,
so the corpus can live wherever you keep it:

```sh
export SETT_CORPUS=/wherever/you/put/it     # default: the path corpus/fetch.sh writes
sett rot                                     # every path the repo asserts — do you have it?
```

> `sett rot` still names every path that is missing on **your** box before you
> waste a GPU hour finding out, and it expands the variables to do it — an
> audit that goes blind when you make paths portable is worse than no audit,
> because it keeps printing the same reassuring word.

`sett selftest` is the honest first command. It runs every gate against every
spec **without a model and without a GPU** — it is what to run before believing
any number in this repo, including mine. `sett selftest --fast` (53s) skips the
two frozen historical specs.

Then rent anything with a GPU on vast.ai and paste the SSH string they give you:

```sh
sett birth "-p <port> root@<ip> -L 8080:localhost:8080" --model glm-q4
sett body                    # what is ACTUALLY served, read from the live endpoint
sett gym code-10             # put the model through a gym
sett score                   # the ledger
sett kill                    # stop paying
```

`sett body` reads the model from the endpoint on every invocation. There is no
pin file to drift. A dead endpoint makes `sett do` exit 3 and say so — it will
not quietly fall back to a cloud model and let you think otherwise.

---

## A gym is four fields

```
## 11 stix-bytes
do:    Write only the byte size of $CORPUS/enterprise-attack-stix21.json to $OUT/11.txt
check: test "$(tr -d '[:space:]' < "$OUT/11.txt")" = "$(stat -c%s $CORPUS/enterprise-attack-stix21.json)"
```

`$OUT`, `$SETT` and `$CORPUS` are expanded before the model ever sees the text,
so the same gym runs on a box that keeps its data somewhere else.
`sett prompts <spec>` prints exactly what gets sent.

The operator writes `do:` and `check:`. The model is handed `do:` and **never**
`check:` — a model that can read the gate can teach to it. One fresh process
per point, so there is no long horizon to lose. No SKIP: PASS or it didn't
happen.

`check:` is a program. Programs cannot be flattered, cannot be bargained with,
and do not care how confident the prose above them sounded.

## Four laws for the checks

1. **The check is a program, not a model.** A program cannot be flattered.
2. **A check must fail when the artifact is absent.** Otherwise it is a fake gate.
3. **A check must fail when the artifact is wrong.** Otherwise it is an existence
   test — and an existence test is what let a hundred-point gym score 100/100
   while proving only that files appeared.
4. **A check must assert against something that cannot move.** Laws 2 and 3 both
   ask about the artifact. Neither asks whether the *ground* is still there.

## Gate the gates before you believe a single score

This is the part nobody builds, and it is the part that matters.

```console
$ sett selftest

spec             A         B         C         D         lint
--------------------------------------------------------------
analyst-12       12/12     12/12     12/12     n/a       7
code-10          10/10     10/10     10/10     n/a       0
code-sett-8      8/8       8/8       8/8       n/a       0
debug-7          7/7       7/7       7/7       0/7       0
flash-100-core   23/23     none      22/23     n/a       12
smoke-3          3/3       none      3/3       n/a       0
stix-graph-12    12/12     12/12     12/12     n/a       0

verbs clean (15 verbs run; unknown verb dies)
rot   clean
leak  clean (no run read its own spec today)
```

| gate | the question | what it caught |
|---|---|---|
| **A** `sett gate` | does the check pass with **no artifact**? | four fake checks at authoring time |
| **B** `sett check --out` | does it pass the **reference implementation**? | checks that were impossible, not hard |
| **C** `sett gate --wrong` | does it pass a **wrong-but-present** artifact? | `smoke-3` p3 · `flash-100-core` p87 |
| **D** `sett gate --broken` | repair gyms: does the **broken input** pass? | gates `debug-7`: 0/7, so no point measures `cp` |
| `sett rot` | does every asserted path and documented verb still **exist**? | the dead law pointer |
| `sett lint` | what must the model **guess** that the operator failed to say? | 7 defects in one spec |
| `sett leak` | did any run **read the spec containing its own checks**? | 15 runs that had the answer key |
| `sett ab` / `sett runs` | is this difference **real**, or one run's luck? | a 6-vs-4 "result" that was noise |

Read that table as a confession. Every entry in the right-hand column is a
defect these tools found **in my own work**, and finding them is the entire
return on the labour.

## The fourth law was paid for

`smoke-3` point 3 computed its expected value with `find` over
`/home/michael/probe/specs`. That directory vanished when `probe` was merged
into `sett`. `find` on a missing directory returns nothing, so the expected
value silently became `0`.

The check did not break. It **inverted**: the model's correct answer, `4`,
began FAILING, and a garbage answer, `0`, began PASSING. It had been sitting in
the ledger as a PASS.

The same bug was in the law itself. `SEAT.md` told the model to verify its work
with a tool that no longer existed — so every gym ever run had been scored
under instructions that exit 127.

And a third costume: `code-sett-8` point 2 asserted `["pass"]==3` against an
append-only state file that the next run would have changed underneath it.

One bug, three costumes: **a check whose expected value is computed from
something that can move.** Hence `fixtures/`, hence `sett rot`, hence the
fourth law.

## The ledger records the conditions, not just the score

```console
$ sett score
== ledger ==  computed from runs/*/state.tsv, conditions from runs.tsv

spec             score   reps       model                spec@    when             law
------------------------------------------------------------------------------------------------
code-10          9/10    9,7,9      glm-4.7-flash        182cc6   2026-07-31 13:27 -
code-sett-8      7/8     8,7,7      glm-4.7-flash        4f3a2a   2026-07-31 13:10 -
debug-7          3/7     5,5,3      glm-4.7-flash        4fce52   2026-07-31 14:07 -
smoke-3          3/3     -          glm-4.7-flash        02b6a0   2026-07-31 12:49 -
```

`spec@` is the hash of the gym text the score was earned against. Edit a `do:`
line and every number recorded against it silently becomes a number about a
different gym — so `sett score` marks it `(!)` and says so. A score without its
model, its law and its task text is not a measurement.

`reps` is there because one run is an anecdote. `code-10` scoring 9 is a
different claim from `code-10` scoring 9, 7, 9 — and only the second one is
true.

`sett score --doc` is [RESULTS.md](RESULTS.md): the written record, the
analysis, and the caveats.

---

## The verbs

```sh
# the body
sett birth "<ssh string>" [--model glm-q4]   rent, provision, wire, verify
sett body                    what is ACTUALLY served — live endpoint, never a file
sett do "<task>"             one bounded task under SEAT.md
sett doctor [--fix]          the endpoint is truth; find and fix pin drift
sett kill                    stop paying

# the gym
sett new <name>              scaffold a spec
sett gym <spec>              run pending points, fresh process each
sett runs <spec> <n>         fly it n times, keeping every rep's artifacts
sett ab <spec> <n> <A> <B>   n runs per arm — is the difference real or luck?
sett status <spec>           what passed, what is pending
sett report <spec>           write REPORT.md

# the instruments
sett selftest [--fast]       every gate on every spec — is the instrument sound?
sett gate <spec>             mutation-test the CHECKS (--wrong, --broken)
sett prompts <spec>          the exact text the model receives, expanded
sett check <spec> [--out D]  re-run every check, read-only, no model
sett lint <spec>             operator defects that read as model failures
sett rot                     every path and verb this repo asserts — still real?
sett leak [since]            did a run read the spec with its own checks?
sett score [--doc]           the ledger
sett vault seal|check <name> prove nothing was lost
```

## The words

Every specialised term in this repository names a way the **operator** can fool
himself. The model only gets the plain words — `artifact`, `PASS`, `FAIL`,
`ERROR`. That is the same ratio as the defects above, and it is not a
coincidence.

[GLOSSARY.md](GLOSSARY.md) has all of them: `inversion`, `existence test`,
`impostor`, `rot`, `lint`, `leak`, `drift`, `confound`, `negative control`,
`SOLID` / `NOISY` / `DEAD` / `SIGNAL`.

> *Der Begriff* — the one word that describes a fixed thing rather than
> something omnipresent. A clear and straight line.

Description gestures at something ungrippable. A Begriff has an address. You
cannot write a check that detects carelessness; you can write one that detects
a gate which passes with no artifact — and that is the same failure, wearing
clothes you can grip.

## The map

```
sett            the program. one file of bash.
specs/          gyms. one bounded task, one artifact path, one machine check.
lib/            the instruments sett calls: gates, rot, lint, leak, ab, selftest.
corpus/         manifests and fetch.sh for the data the checks grip on.
fixtures/       frozen inputs. the ground that cannot move.
reference/      a working implementation per gym — gate B's answer key.
docs/           the guided tour, and dated records of what happened.
RESULTS.md      model × gym × score, with the caveats.
GLOSSARY.md     the terms, and who each one is about.
SEAT.md         the law a task runs under.
```

## Where it came from

Fifteen repositories built this apparatus and buried it inside a harness. Same
organ, fifteen names, never once the product:

| | | |
|---|---|---|
| `project_michael` | May | the four-header context package; the `commit_changes` gate |
| `Hermes` | Jul 5 | **Verification Gauntlet** — *"the doer doesn't grade its own homework"* |
| `MoR` | Jul 17 | **The Audit** — a falsification state entered *before* speaking |
| `KARL` | Jul 19 | structured handoffs; bounded reasoning |
| `MoRE` | Jul 20 | *"a turn that changed files but ran nothing is bounced once"* |
| `KM1` | Jul 20 | a night shift judged by **a benchmark it cannot game** |
| `KM2` | Jul 21 | the hash-chained ledger — *"the ledger makes faith obsolete"* |
| `KM` | Jul 28 | the DEMO law · canary > `/v1/models` 200 |
| `karte/RULES.md` | Jul 28 | R2 different mouths · R5 shallow diary = REJECT · R11 ground-first |

Fifteen died of writing the agent loop — the free layer, the one that improves
without me. **Nothing died of writing an instrument.**

A sett is a badger's den. It is dug once and extended by generation after
generation, for decades. No badger has ever abandoned a sett because the
architecture was wrong.

That is the whole rule. This repository is extended. It is never restarted.

---

*Guided tour with real console output: [docs/SHOWCASE.md](docs/SHOWCASE.md).*
