#!/usr/bin/env bash
# selftest — is the instrument still sound?
#
# Every gate, every spec, one command. Run it after any change to a spec, a
# check, or sett itself. It answers the only question that matters before a
# score can be believed: are the gates still real?
#
#   A     the check fails when the artifact is ABSENT
#   B     the check passes the REFERENCE implementation
#   C     the check fails a plausible WRONG artifact
#   D     repair gyms only: the check fails the BROKEN input it hands over
#   lint  operator defects that read as model failures
#   rot   every path asserted and every documented verb, still real
#
# Exit 0 only when every gate on every spec holds. Known-and-accepted
# exceptions live in selftest.accept, each with a reason, and are printed
# rather than hidden — an exception you cannot see is an exception you will
# forget you made.
#
# usage: sett selftest [--quiet] [--fast]
set -uo pipefail
cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.."   # lib/ -> repo root
Q=0; FAST=0
for a in "$@"; do
  case "$a" in
    --quiet) Q=1 ;;
    # --fast skips the historical specs, whose gates are frozen and whose
    # exceptions are already accepted. Full run is ~118s and flash-100-core
    # alone is ~30s of it; a check too slow to run before a commit is a check
    # that does not get run.
    --fast)  FAST=1 ;;
  esac
done
say(){ [ "$Q" -eq 1 ] || printf '%s\n' "$*"; }

accepted() { grep -qxF "$1" selftest.accept 2>/dev/null; }

fail=0
say "== sett selftest =="
say
say "$(printf '%-16s %-9s %-9s %-9s %-9s %-6s' spec A B C D lint)"
say "$(printf '%.0s-' {1..62})"

for f in specs/*.probe; do
  s="$(basename "$f" .probe)"
  if [ "$FAST" -eq 1 ]; then
    case "$s" in flash-100-core|analyst-12) say "$(printf '%-16s %s' "$s" '(skipped: --fast)')"; continue ;; esac
  fi

  a="$(./sett gate "$s" 2>/dev/null | tail -1 | grep -oE '[0-9]+/[0-9]+' | head -1)"
  c="$(./sett gate "$s" --wrong 2>/dev/null | tail -1 | grep -oE '[0-9]+/[0-9]+' | head -1)"
  dout="$(./sett gate "$s" --broken 2>/dev/null | tail -1)"
  case "$dout" in
    *"not a repair gym"*) d="n/a" ;;
    *) d="$(printf '%s' "$dout" | grep -oE '0/[0-9]+' | head -1)"; [ -z "$d" ] && d="BROKEN" ;;
  esac
  l="$(./sett lint "$s" 2>/dev/null | grep -cE '^[0-9]+\s')"

  if [ -d "reference/$s-reference" ]; then
    rm -rf /tmp/selftest-ref; cp -r "reference/$s-reference" /tmp/selftest-ref
    rm -rf /tmp/selftest-ref/__pycache__; chmod +x /tmp/selftest-ref/*.sh 2>/dev/null
    b="$(./sett check "$s" --out /tmp/selftest-ref 2>/dev/null | tail -1 | grep -oE '[0-9]+/[0-9]+' | head -1)"
  else
    b="none"
  fi

  say "$(printf '%-16s %-9s %-9s %-9s %-9s %-6s' "$s" "$a" "$b" "$c" "$d" "$l")"

  # --- judgement -------------------------------------------------------
  for pair in "A:$a" "C:$c"; do
    g="${pair%%:*}"; v="${pair#*:}"
    [ -n "$v" ] && [ "${v%%/*}" = "${v##*/}" ] || { accepted "$s:$g" || { fail=$((fail+1)); say "   ! gate $g not clean on $s"; }; }
  done
  if [ "$b" = "none" ]; then
    accepted "$s:B" || { fail=$((fail+1)); say "   ! no reference implementation for $s — gate B unproven"; }
  elif [ "${b%%/*}" != "${b##*/}" ]; then
    accepted "$s:B" || { fail=$((fail+1)); say "   ! reference does not pass $s"; }
  fi
  [ "$d" = "BROKEN" ] && { fail=$((fail+1)); say "   ! gate D: a broken input PASSES on $s — that point measures cp"; }
  [ "$l" != "0" ] && { accepted "$s:lint" || { fail=$((fail+1)); say "   ! $l lint defect(s) on $s"; }; }
done

# --- the program itself, not just the gates -----------------------------
# Every gate above tests a SPEC. Nothing tested `sett`. Eight verbs were added
# in one night — rot, lint, leak, ab, runs, selftest, check --out, gate
# --broken — and a typo in the dispatch case would not have failed any gate.
say
vfail=0
while IFS='|' read -r label cmd; do
  [ -n "$label" ] || continue
  eval "$cmd" >/dev/null 2>&1; rc=$?
  # 0 = fine, 1 = a real "found something" answer. 2+ = die/usage/crash.
  [ "$rc" -le 1 ] || { say "  ! verb failed: $label (exit $rc)"; vfail=$((vfail+1)); }
done <<'VERBS'
sett help|./sett help
sett body|./sett body
sett doctor|./sett doctor
sett score|./sett score
sett score --doc|./sett score --doc
sett status|./sett status code-10
sett check|./sett check code-10
sett check --out|./sett check code-10 --out reference/code-10-reference
sett gate|./sett gate code-10
sett gate --wrong|./sett gate code-10 --wrong
sett gate --broken|./sett gate debug-7 --broken
sett lint|./sett lint code-10
sett rot|./sett rot
sett leak|./sett leak
sett report|./sett report code-10
VERBS
# an unknown verb MUST die rather than silently succeed
./sett definitely-not-a-verb >/dev/null 2>&1 && { say "  ! unknown verb did not die"; vfail=$((vfail+1)); }
if [ "$vfail" -eq 0 ]; then say "verbs clean (15 verbs run; unknown verb dies)"; else fail=$((fail+vfail)); fi

r="$(./sett rot --quiet >/dev/null 2>&1; echo $?)"
if [ "$r" -eq 0 ]; then say "rot   clean"; else say "rot   ROT PRESENT"; fail=$((fail+1)); fi

lk="$(./sett leak "$(date +%Y-%m-%d) 00:00" >/dev/null 2>&1; echo $?)"
if [ "$lk" -eq 0 ]; then say "leak  clean (no run read its own spec today)"; else say "leak  A RUN READ ITS OWN SPEC"; fail=$((fail+1)); fi

if [ -s selftest.accept ]; then
  say
  say "accepted exceptions (selftest.accept):"
  grep -vE '^#|^$' selftest.accept | while read -r line; do say "  $line"; done
fi

say
if [ "$fail" -eq 0 ]; then
  say "selftest: PASS — every gate holds on every spec"
  exit 0
fi
say "selftest: $fail problem(s)"
exit 1
