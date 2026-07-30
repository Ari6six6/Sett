# fixtures/specs

Frozen `.probe` files used as INPUT by points that must parse a spec.

They exist because of a real leak. `code-sett-8` points 3, 4 and 7 asked the
model to "read a SETT .probe spec" without naming one. The model went looking,
found `specs/`, and opened `specs/code-sett-8.probe` — the file holding its own
checks. `sett leak` found 15 runs that did this on 2026-07-30. One transcript
shows the model reasoning about `check:` lines; point 4's check states its
expected answers outright (`5/12`, `1/3`).

No artifact was found to have hardcoded an expected value. The leak was
available and not taken — luck, not design.

Two rules follow:

1. **A point that needs a file must name that file.** Vagueness sends the model
   browsing, and browsing is how it finds the answer key.
2. **The file it names must be frozen.** `specs/*.probe` are live and edited;
   asserting against them is the same bug as the deleted directory and the
   append-only `state.tsv`.

| file | frozen from | stable facts |
|---|---|---|
| `sample-12.probe` | `specs/analyst-12.probe` | 12 points; 5 of 12 do: lines name a `/home/` path; 12 checks |
| `sample-3.probe` | `specs/smoke-3.probe` | 3 points; 1 of 3 grounded |
