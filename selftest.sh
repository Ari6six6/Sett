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
# usage: ./selftest.sh [--quiet]
set -uo pipefail
cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
Q=0; [ "${1:-}" = "--quiet" ] && Q=1
say(){ [ "$Q" -eq 1 ] || printf '%s\n' "$*"; }

accepted() { grep -qxF "$1" selftest.accept 2>/dev/null; }

fail=0
say "== sett selftest =="
say
say "$(printf '%-16s %-9s %-9s %-9s %-9s %-6s' spec A B C D lint)"
say "$(printf '%.0s-' {1..62})"

for f in specs/*.probe; do
  s="$(basename "$f" .probe)"

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

say
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
