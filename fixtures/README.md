# fixtures

Frozen inputs for checks. **Nothing in here is ever written by a run.**

## Why this directory exists

`code-sett-8` point 2 asserted:

```
summary("/home/michael/SETT-repo/runs/smoke-3/state.tsv")["pass"] == 3
```

`runs/*/state.tsv` is append-only live state. The next `sett gym smoke-3`
appends verdicts, the count stops being 3, and the check begins failing
correct code — with nothing in the repo having changed.

That is the same failure as `smoke-3` point 3, which computed ground truth
with `find` over a directory that had been deleted, and the same as `SEAT.md`
pointing at `/home/michael/probe/probe`. Three costumes, one bug:

> **a check whose expected value is computed from something that can move.**

`rot.sh` catches paths that *vanish*. It cannot catch a path that still exists
and now says something different. The only real defence is to assert against
something frozen.

## The rule

A check may read live state to *report*. A check may only assert against:

- a corpus under `/home/michael/lab/` (immutable, sealed in the vault), or
- a file in this directory, or
- a temp file the check itself creates.

Never against `runs/`, never against `out/`, never against a directory listing.

## Contents

| file | frozen from | asserts |
|---|---|---|
| `state-3pass.tsv` | `runs/smoke-3/state.tsv`, 2026-07-30 | 3 ids, all PASS, one duplicate-free |
