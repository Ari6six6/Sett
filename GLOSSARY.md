# Glossary

> *Der Begriff* — the one word that describes a fixed thing, rather than
> something omnipresent. A clear and straight line.
>
> **Begriff translates as: Straight.**

Description gestures at something ungrippable. A Begriff has an address.

That distinction is the whole reason this file exists, and it is worth stating
before the first term: everything in this repository that took work to name was
named so a *program* could find it. You cannot write a check that detects
carelessness. You can write one that detects a gate which passes with no
artifact — and that is the same failure, wearing clothes you can grip.

---

## Who these terms are about

Sort the vocabulary by whom each word indicts.

**Words whose subject is the model:** `artifact`, `PASS`, `FAIL`, `ERROR`.
Four words, all of them plain English that needed no coining.

**Words whose subject is the operator:** fake gate, existence test, impostor,
reference implementation, gates A/B/C/D, ground truth, the fourth law,
inversion, rot, lint, leak, drift, pin, `spec@`, confound, negative control,
n, arm, SOLID, DEAD, NOISY, SIGNAL, `solid?`.

**Every specialised term here names a way the operator can fool himself.** The
model only gets the plain words. That is the same 7:1 ratio as the defects
these instruments found — seven mine, one the model's — and it is not a
coincidence. The vocabulary and the findings came from the same place.

Note the grammar. *The check* inverted. *The path* rotted. *The run* read its
own spec. Never "I was careless", even though that is what happened every
time. A failure attached to a person is a feeling you can apologise for and
learn nothing from. A failure attached to an artifact is an address you can
`grep`. The terms point at you and refuse to say your name, which is what makes
them usable at 3am without flinching.

---

## The body — the rented machine

**box** — the rented GPU machine.

**endpoint** — the URL serving the model. *The endpoint is truth*: never ask a
file which model is running, ask the thing that is running. Files were written
once and are confident forever.

**tunnel** — the SSH forward that makes the box's port appear as localhost.

**drift** — a file claiming one thing while reality is another. `sett doctor`
hunts it. A config once read `glm-4.7-flash-q6` while the box served
`glm-4.7-flash`; every benchmark after that would have carried the wrong name.

**seat / law** — `SEAT.md`, the system prompt a run works under.
**bare / bareseat** — a run with no law attached.

## The gym — how work is defined

**gym** — one `.probe` file: a set of tasks.

**point** — one task. The atom. Ten points, ten fresh processes.

**do:** — the instruction the model sees.
**check:** — the bash program that grades it. The model never sees `check:`; a
model that can read the gate can teach to it.

**artifact** — the file the model must leave behind. From `READY` (5 bytes) to
a working program. It is the only thing that survives the process that made
it, so it is the only thing that can be graded. Hence *paths or it didn't
happen*.

**verdict** — `PASS`, `FAIL`, or `ERROR`. FAIL is wrong. ERROR never arrived —
crashed or timed out. Keeping those apart is how `debug-7` was found to stall
rather than merely fail.

**fresh process per point** — every point gets a new model process. No memory
of the last one: nothing to forget, no context to poison, no long horizon to
lose.

## The gates — why a number can be believed

**fake gate** — a check that passes with no artifact at all. Measures nothing,
reads as success.

**existence test** — a check that only proves a file appeared. This is what let
a hundred-point gym score 100/100 while proving nothing.

**impostor** — a deliberately wrong-but-plausible artifact, planted to see
whether the check notices: a module defining every required function and
returning `[]` from all of them.

**reference implementation** — a known-correct solution kept in `reference/`.
A gate nothing can pass is not strict, it is broken.

| gate | asks |
|---|---|
| **A** | does the check fail with **no artifact**? |
| **B** | does it pass a **correct** implementation? |
| **C** | does it fail a **wrong** artifact? |
| **D** | repair gyms: does the **broken input** fail? |

**ground truth** — what a check compares against. **The fourth law: it must be
something that cannot move.**

**inversion** — the failure that named this project. A check whose ground truth
was deleted did not break; it flipped. The correct answer began failing,
garbage began passing, and the row still read PASS. *A broken check screams. An
inverted check smiles at you.*

**rot** — an asserted path or documented command that no longer exists.

**lint** — something the model must **guess** because the operator failed to
say it. Every guess is a coin flip you built, and it will read as a model
failure when it lands wrong.

**leak** — a run reading the spec that contains its own checks.

## The ledger — the record

**ledger** — the score table. `sett score`.

**spec@** — the hash of the gym text a score was earned against. Edit one `do:`
line and every number recorded against it silently becomes a claim about a gym
that no longer exists. Flagged `(!)`.

**pin** — a frozen sha256 of the corpus. CISA's catalogue gained one entry in
three days, 1655 → 1656. Without the pin you would never learn your numbers had
changed worlds.

**vault / gold** — `sett vault check gold`: 15 132 files hashed, proving nothing
was lost.

## The statistics — how not to fool yourself

**n** — how many times you ran it. **n=1 is an anecdote.**

**rep** — one repetition. **arm** — one condition being compared.

| bucket | meaning |
|---|---|
| **SOLID** | passes in every rep |
| **DEAD** | fails in every rep |
| **NOISY** | flips between reps — can support no claim at all |
| **SIGNAL** | stable within each arm, different across arms — the only rows that mean anything |
| **solid?** | passed every time so far, but at n<3 |

`solid?` exists because the tool built to catch coin flips once called one rock
solid. A point seen passing twice can still be a coin flip.

**confound** — a second thing that changed at the same time, so the result
cannot be attributed. When the spec text and the box both moved, the finding is
*supported*, not *proven*.

**negative control** — deliberately breaking something to confirm the detector
notices. A wrong hash was planted to prove the `(!)` flag fires, then the true
one to prove it clears. **A detector you have never seen fire is not a
detector.**

---

## The three to keep

If you keep only three: **inversion**, **existence test**, **noisy**.

Everything else in this repository is machinery for catching those.

---

## Added after the fact

**`$SETT` / `$CORPUS`** — the repo root and the corpus root, expanded in `do:`,
`check:` and the `out:` header before the model or the check ever sees them.
Specs name these instead of one operator's home directory. `sett prompts`
prints the result.

**cosmetic refactor** — a change to a spec *file* that provably does not change
the *rendered prompt*. Replacing a hardcoded path with `$CORPUS` moves the
`spec@` hash, so `sett score` flags every score recorded against it — correctly
in general, wrongly here. The claim is settled by rendering both versions and
diffing, never by assertion. **A refactor you cannot prove was cosmetic is not
a refactor, it is a rewrite.**

**blind audit** — an audit that silently narrows its own scope. Making the
specs portable took `sett rot` from 31 asserted paths to 13 and it still
printed `clean`, because it was grepping for `/home/...` and the paths now said
`$CORPUS/...`. Worse than no audit: no audit is honestly silent, a blind one
keeps saying the reassuring word. Now rot expands the variables first, and a
planted dead path is caught through them.

**both mouths** — the model being graded and the model doing the grading. Until
`sett behave --session`, only the cheap one was ever measured. Asked a similar
question, they answered similarly: **67% versus 68%** checked their own work.

Read that as a statement about **habit, not ability**. The two figures are not
the same measurement — one counts artifact re-reads per gym point, the other
counts verification commands after a file change — so the near-match may be an
artefact of how both were defined. What it does not say is that the two models
are equally capable; the gym scores measure that, and they differ.

What it does say is that the mouth doing the checking ran at 68% too. Neither
rate is good enough, which is the argument for instruments over trying harder.
