#!/usr/bin/env bash
# blind — break the world on purpose and check the instruments still complain.
#
# Three defects in one day were the same defect:
#
#   rot     audited paths matching /home/... The specs became portable and said
#           $CORPUS/... instead. Coverage fell 31 -> 13 and it printed "clean".
#   lint    knew two file formats by name. A gym introduced a third; lint
#           reported 0 while the point it should have flagged scored 0/3.
#   gate C  lost the parser it depends on and reported "0/0 ... 0 FAKE", exit 0.
#           selftest called that clean on every spec, because 0 == 0.
#
# None was found by reading code. Each was found by deliberately breaking the
# world and noticing the instrument stayed quiet. That method is the finding,
# so it belongs in the repo rather than in a commit message.
#
#   An instrument narrows to the world that existed when it was written,
#   and keeps printing the same reassuring word while it does.
#
# Every case here is a NEGATIVE CONTROL on a tool: it must FAIL while the world
# is broken, and PASS again once it is restored. A detector never seen firing
# is not a detector — and an instrument nobody has tried to blind is one you
# are trusting.
#
# usage: sett blind
set -uo pipefail
cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.."   # lib/ -> repo root

pass=0; fail=0
TMP="$(mktemp -d)"; trap 'rm -rf "$TMP"' EXIT

# case <name> <expectation> ; runs break(), asserts, runs restore()
report() { # report <name> <ok|no> <detail>
  if [ "$2" = ok ]; then
    printf '  \033[32mOK\033[0m    %-34s %s\n' "$1" "$3"; pass=$((pass+1))
  else
    printf '  \033[31mBLIND\033[0m %-34s %s\n' "$1" "$3"; fail=$((fail+1))
  fi
}

echo "== blind: break the world, demand a complaint =="
echo

# ── 1. gate C without its spec parser ───────────────────────────────────
# Was: printed "0/0 checks reject a plausible impostor, 0 FAKE" and exited 0.
if [ -d reference/code-sett-8-reference ]; then
  mv reference/code-sett-8-reference "$TMP/parser"
  ./sett gate code-10 --wrong >/dev/null 2>&1; rc=$?
  mv "$TMP/parser" reference/code-sett-8-reference
  [ "$rc" -ne 0 ] && report "gate C, parser removed" ok "exits $rc" \
                  || report "gate C, parser removed" no "exited 0 over an empty set"
else
  report "gate C, parser removed" no "reference/code-sett-8-reference absent"
fi

# ── 2. selftest must not call an empty gate clean ───────────────────────
if [ -d reference/code-sett-8-reference ]; then
  mv reference/code-sett-8-reference "$TMP/parser"
  out="$(./sett selftest --fast 2>&1)"; rc=$?
  mv "$TMP/parser" reference/code-sett-8-reference
  if [ "$rc" -ne 0 ] && printf '%s' "$out" | grep -q 'gate C'; then
    report "selftest, gate C empty" ok "fails and names gate C"
  else
    report "selftest, gate C empty" no "did not fail on an empty gate"
  fi
fi

# ── 3. rot must see through $CORPUS, not only literal /home paths ───────
# Was: specs went portable, rot's coverage fell 31 -> 13, still said "clean".
before="$(./sett rot 2>/dev/null | grep -oE '\([0-9]+ paths' | grep -oE '[0-9]+')"
cp specs/code-10.probe "$TMP/c10"
sed -i 's|\$CORPUS/kev/known_exploited_vulnerabilities.json|$CORPUS/kev/NO-SUCH-FILE.json|' specs/code-10.probe
./sett rot >/dev/null 2>&1; rc=$?
cp "$TMP/c10" specs/code-10.probe
[ "$rc" -ne 0 ] && report "rot, dead path behind \$CORPUS" ok "exits $rc, ${before:-?} paths audited" \
                || report "rot, dead path behind \$CORPUS" no "stayed clean through a dead path"

# ── 4. lint must catch a schema a sibling explains and this point does not ──
# Was: hardcoded to state.tsv and .probe, so a third format was invisible.
cat > "$TMP/blindtest.probe" <<'SPEC'
# spec: blindtest
# out:  $SETT/out/blindtest

## 1 explains
do:    The widget table has columns alpha, beta, gamma. Write the count to $OUT/1.txt
check: test -s "$OUT/1.txt"

## 2 silent
do:    Read the widget table and write the count of rows to $OUT/2.txt
check: test -s "$OUT/2.txt"
SPEC
cp "$TMP/blindtest.probe" specs/blindtest.probe
n="$(./sett lint blindtest 2>/dev/null | grep -cE '^[0-9]+\s')"
rm -f specs/blindtest.probe
[ "${n:-0}" -gt 0 ] && report "lint, unexplained schema" ok "$n finding(s) on a novel table" \
                    || report "lint, unexplained schema" no "silent on a schema asymmetry"

# ── 5. leak must notice a run that read its own spec ────────────────────
mkdir -p "$TMP/sessions/x-out-code-10--"
printf '{"t":"read","path":"specs/code-10.probe"}\n' > "$TMP/sessions/x-out-code-10--/s.jsonl"
# Assert on the EXIT CODE, not on a substring. The first version of this case
# grepped for "read its own" — which appears verbatim in leak's CLEAN message,
# "no run read its own spec" — so it passed regardless of what leak did. A
# blind test that is itself blind is the joke this file exists to prevent.
# The clean arm must be a real empty SCAN, not a missing directory: leak exits
# 0 early when $SESS does not exist, which would make this arm pass for the
# wrong reason. Create it first.
mkdir -p "$TMP/empty"
SETT_SESSIONS="$TMP/sessions" ./sett leak >/dev/null 2>&1; rc=$?
SETT_SESSIONS="$TMP/empty" ./sett leak >/dev/null 2>&1; rc_clean=$?
if [ "$rc" -ne 0 ] && [ "$rc_clean" -eq 0 ]; then
  report "leak, planted self-read" ok "fires on the plant (exit $rc), clean without it"
else
  report "leak, planted self-read" no "plant=$rc clean=$rc_clean — not discriminating"
fi

echo
if [ "$fail" -eq 0 ]; then
  echo "blind: PASS — $pass instrument(s) complained when the world broke"
  exit 0
fi
echo "blind: $fail instrument(s) stayed quiet while blind, $pass complained"
echo "       An instrument that does not notice its own world vanishing is"
echo "       printing a reassuring word, not performing an audit."
exit 1
