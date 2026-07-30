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
