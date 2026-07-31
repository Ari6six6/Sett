# Corpus

The checks grip on these. A gym is only as honest as the data under it, so the
exact bytes are pinned. If a hash changes, the scores in `RESULTS.md` refer to a
different world and must be re-run.

| file | bytes | sha256 (first 16) | door |
|---|---|---|---|
| `enterprise-attack-stix21.json` | 53,277,393 | `bdf1ce86a4e60421` | MITRE ATT&CK Enterprise, STIX 2.1 |
| `known_exploited_vulnerabilities.json` | 1,565,938 | `e0326281b91c4f9a` | CISA KEV catalog |
| `epss-hardlinks.json` | 2,517 | `3aed727a3fcdb7c5` | FIRST EPSS, scored subset |

Fetched 2026-07-28 · KEV `catalogVersion` 2026.07.27

## Where they come from

```sh
corpus/fetch.sh [DEST]      # DEST defaults to the path the specs name
```

| file | source |
|---|---|
| `enterprise-attack-stix21.json` | `attack-stix-data` → `enterprise-attack/enterprise-attack-19.1.json` (MITRE, GitHub) |
| `known_exploited_vulnerabilities.json` | `cisa.gov/sites/default/files/feeds/` |
| `epss-hardlinks.json` | `api.first.org/data/v1/epss?cve=` — the 26 CVEs that hardlink KEV to ATT&CK |

`fetch.sh` downloads each, refuses anything that is not parseable JSON, and
compares the bytes against the pins above.

**Only ATT&CK can be pinned.** MITRE publishes immutable numbered releases, so
the script asks for `19.1` by name and gets the same 53,277,393 bytes every
time — verified 2026-07-31, sha256 `bdf1ce86…`, byte-identical.

The other two are living feeds and drifting is their normal state. Re-fetched
2026-07-31, three days after the pin:

```
KEV     DRIFT   1567768 bytes   pinned e0326281…  →  got 15b44d7c…
EPSS    DRIFT      2517 bytes   pinned 3aed727a…  →  got 95174f21…
```

KEV gained exactly one entry in three days: **1655 → 1656**.

That single row is the whole argument for this file. Any check that had
hardcoded `1655` as its expected value would now fail a model that answered
`1656` — which is the *correct* answer about today's catalog. The check would
not break; it would **invert**, exactly as `smoke-3` point 3 did.

Audited 2026-07-31: no check in `specs/` hardcodes a corpus-derived constant.
Every one recomputes its expected value from the file it grades against, so a
refreshed corpus moves the answer and the check follows it. What a refresh
*does* invalidate is comparison — a score computed against 1656 entries is not
the same measurement as one in `RESULTS.md`, and `fetch.sh` says so out loud.

## Why these

All three are machine-readable, exactly answerable, and free. That is the whole
selection criterion, and it generalises: **the apparatus only has teeth where
ground truth is mechanically decidable.**

Given ATT&CK and KEV, a 30B model scored 10/12 on multi-step joins.
Given a literary corpus that was never indexed, the same class of model invented
characters that do not exist. Same model. Different grip.

## Adding a corpus

1. Land it with a manifest recording the source URL and fetch date.
2. Pin size and sha256 here.
3. Write points whose `check:` recomputes the answer from the raw file — never
   from a derived index, and never from the artifact being graded.
4. Run `probe sanity` before any model sees the spec.

## Not in this repository

The corpora themselves. ATT&CK is 53 MB and belongs to MITRE; KEV belongs to
CISA; EPSS belongs to FIRST. This repository pins what they were, not what they
are. Fetch them from their own doors.
