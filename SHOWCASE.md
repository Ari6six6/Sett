# SETT

**Rent a GPU. Seat a model. Make it prove every claim it makes.**

One bash script. Four hands: `read`, `write`, `edit`, `bash`. No agent loop of
its own — it calls `pi` once per task and gets out of the way.

Everything below is real output from one afternoon on this box, 2026-07-30.

---

## 60 seconds: cold machine to working agent

```sh
curl -fsSL https://raw.githubusercontent.com/Ari6six6/KM/main/setup.sh | bash -s -- \
    --gpu "-p 46023 root@219.122.229.5 -L 8080:localhost:8080" --model glm-q4
```

That's it. That is the whole install. Rent anything with a GPU on vast.ai,
copy the SSH string they hand you, paste it in.

```
✓ Node v22.23.1 already present
✓ pi already installed (0.83.0)
✓ box reachable
✓ 1× GPU · 47GB VRAM  (NVIDIA RTX 6000 Ada Generation)
  serving GLM-4.7-Flash · Q4_K_M GGUF · context 65536 · box port 8080
✓ capability ok
✓ disk ok (62GB free, need ~20GB)
▸ building llama.cpp with CUDA on the box (first time takes several minutes)…
! port 8080 is held on the box — sliding the server to 18080
  tunnel follows the slide → -L 8080:localhost:18080
✓ tunnel up (pid 94212)
  weights 18.0GB/18.0GB  100%
✓ the model is up at http://localhost:8080/v1
  (the model answered a tool call — it can think)
```

Note line four from the bottom. **The port was taken and it slid, then moved
the tunnel to match.** You did not have to know that happened.

Note the last line. It does not say "server started." It says the model
answered a tool call. A port that accepts TCP is not a model that can think,
and the difference is the entire point of this program.

---

## The one rule

> **SETT never implements the agent loop.**

`sett do` is one `exec` of `pi` and nothing more:

```bash
cmd_do() {
  local m; m="$(require_body)"
  echo "seat: km-box/$m   law: $SEAT" >&2
  exec pi -p "$*" --model "km-box/$m" --append-system-prompt "$SEAT"
}
```

The day a `while` loop appears around a model turn in `sett`, this has become
the sixteenth harness, and the badger goes back in the ground.

---

## The endpoint is the only truth

Every config file on your disk is a rumour. Only the live endpoint knows what
is actually being served.

```console
$ sett doctor
== endpoint ==
  LIVE   http://localhost:8080 serves: glm-4.7-flash
== files that claim otherwise ==
  ok     /home/michael/.km/state.json
  DRIFT  /home/michael/.km/agent-model = km-box/glm-4.7-flash-q6
                                      != km-box/glm-4.7-flash
  ok     /home/michael/.pi/agent/models.json
  ok     /home/michael/.km/herald.json seat=km-box/glm-4.7-flash

fix (only when the endpoint is LIVE):  sett doctor --fix
```

That DRIFT is real. It was left behind by a previous flight that served a
different quantisation. Every benchmark you ran after that point would have
been labelled with the wrong model name — and you would never have known,
because the file said so with total confidence.

---

## A gym is four fields

```
## 8 stix-resolve-refs
do:    Write a Python file $OUT/8.py defining group_software(path, group_name)
       which loads a STIX bundle and returns a sorted list of distinct names of
       malware or tool objects that the intrusion-set named group_name "uses".
       Resolve relationship objects via source_ref and target_ref.
check: python3 -c '...assert g==e, (len(g),len(e))'
```

The operator writes `do:` and `check:`. The model is handed `do:` and never
`check:`.

`check:` is a **program**. Programs cannot be flattered, cannot be
bargained with, and do not care how confident the prose above them sounded.

---

## Gate the gates before you trust a single score

This is the part nobody builds, and it is the part that matters.

**Gate A — does the check fail when the artifact is missing?**

```console
$ sett gate code-10
1     dedupe-order      ok (fails without artifact)
...
sanity: 10/10 checks are real, 0 FAKE
```

**Gate C — does it fail on a *plausible wrong* artifact?**

It plants an impostor with the right shape and wrong behaviour: for every
`.py` a module defining every function the task names, each returning `[]`;
for every `.sh` an executable that exits 0 with believable output.

```console
$ sett gate code-10 --wrong
1     ok (rejects wrong-but-present)
...
gate C: 10/10 checks reject a plausible impostor, 0 FAKE
```

Why both exist: an earlier gym scored **100/100** and meant only *"a hundred
files appeared."* Gate A caught four fake checks at authoring time. Gate C
caught one that had been sitting in the ledger marked PASS.

**Gate R — has the ground moved under the check?**

```console
$ sett rot
== paths asserted by this repo ==
clean: every asserted path exists and every documented verb resolves
       (20 paths, 2 allowlisted in rot.ignore)
```

This one was paid for in blood. A check computed its expected value with
`find` over a directory that had been **deleted**. `find` on a missing
directory returns nothing, so the expected value silently became `0`.

The check did not break. It **inverted**. The correct answer began FAILING and
a garbage answer began PASSING — and it sat in the ledger as a PASS.

`sett rot` also cross-checks every command your docs tell people to run
against the verbs that actually exist, because RESULTS.md spent a month
telling readers to run a tool that had been deleted.

---

## Now run it

```console
$ sett gym code-10
1     dedupe-order                 PASS
2     merge-intervals              PASS
3     flatten-dict                 PASS
4     retry-backoff                PASS
5     kev-count-lib                PASS
6     kev-to-csv                   PASS
7     stix-histogram-lib           PASS
8     stix-resolve-refs            PASS
9     cli-tool                     FAIL
10    spec-linter                  PASS

run: 9 PASS  1 FAIL  0 ERROR  (0 already passing, 10 points)
```

A 30-billion-parameter model, on a card you rented by the hour, wrote working
code against 25 842 real STIX objects and 1 655 real CISA KEV entries. Point 8
resolved `source_ref`/`target_ref` across the whole bundle. First attempt. No
retries.

Fresh process per point. No long horizon to lose, nothing to forget, no
context to poison.

**And the one failure was not a coding failure.** It reached for `jq`, which
isn't installed on that box, and assumed a JSON shape it never checked. Facts
about the machine, not gaps in ability. Those facts now live in the law.

---

## Re-verify anything, any time, with no model at all

```console
$ sett check code-10
verify: 9/10 PASS  1 FAIL   (read-only, no model, out=…/out/code-10)
```

Same nine. Same one. Reproduced exactly, from artifacts on disk.

No GPU. No tokens. No network. The artifacts are on disk and the checks are
programs, so last week's score is reproducible today for free.

---

## One run is an anecdote

```console
$ sett ab code-sett-8 3 SEAT-bare.md SEAT-repaired.md

id  arm A     arm B     bucket
1   2/2       1/2       NOISY
2   0/2       1/2       NOISY
3   2/2       2/2       SOLID
6   1/2       2/2       NOISY
...
SOLID 4   DEAD 0   NOISY 4   SIGNAL 0

VERDICT: no effect detected.
  4 of 8 points flip WITHIN an arm, so run-to-run variance — not the
  treatment — dominates this measurement. Any story told about the
  difference in totals would be a story about luck.
```

The first pairing came back **6 vs 4** — a clean demonstration that the change
made things worse. The second came back **6 vs 7** — the opposite. Same law,
same model, same box, forty minutes apart.

A tool that reports totals would have let you publish either one. This tool
**refuses to print a verdict** when no point differs stably. It tells you how
many points are coin flips instead, because that number is what says how many
runs your question actually needed.

---

## And it audits itself

```console
$ sett leak
== self-spec reads since 2026-07-30 ==
  LEAK  2026-07-30T19-45-11  gym=code-10       points: 10
  LEAK  2026-07-30T20-13-39  gym=code-sett-8   points: 4
  ...
15 run(s) read the spec containing their own checks.

This does not prove the score is wrong — check whether the artifact
computes its answer or hardcodes it. It proves the score is UNPROVEN,
which for this repo is the same thing.
```

The README used to claim the model never sees `check:`. **That claim was
false.** The model has a `bash` tool and the spec is world-readable at a
predictable path. Several tasks *require* parsing a `.probe` file, so the gym
was actively sending the model toward its own answer key.

Every artifact was inspected. None hardcoded an expected value — the leak was
available and not taken.

That is **luck**, not design, and a program built on the sentence *"the ledger
makes faith obsolete"* does not get to run on luck. So the leak is now
detected across every session `pi` has ever written, retroactively.

**This is the feature.** Not that SETT is clean — that SETT is the thing that
found out it wasn't.

---

## Prove nothing was lost

```console
$ sett vault check gold
checking 15132 files...
vault gold: INTACT — nothing lost, nothing altered
```

Fifteen thousand files, sha256 by sha256, after a full day of provisioning,
gyms, edits and one deleted directory.

---

## Stop paying

```sh
sett kill
```

---

## The whole thing

```sh
sett birth "<ssh string>"     # rent, provision, wire, prove it thinks
sett doctor                   # endpoint is truth; find and fix drift
sett new mygym                # scaffold a spec
sett gate mygym               # A: fake checks?
sett gate mygym --wrong       # C: existence tests?
sett rot                      # R: has the ground moved?
sett gym mygym                # fly it — fresh process per point
sett check mygym              # re-verify, read-only, no model, free
sett ab mygym 3 lawA lawB     # is that difference real, or is it luck?
sett leak                     # did it read its own answer key?
sett score                    # the table
sett vault check gold         # prove nothing was lost
sett kill                     # stop paying
```

---

## Who decides what

| Decision | Who |
|---|---|
| What is worth doing | You |
| How to do it | The model |
| Whether it was done right | **A program** |

The model is good at the middle row. Keep it there and it is worth the rental.

> *The brain proposes. The captain disposes. The ledger makes faith obsolete.*
