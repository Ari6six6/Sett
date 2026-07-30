#!/usr/bin/env bash
# rot — every absolute path this repo ASSERTS, checked against what EXISTS.
#
# Two findings on 2026-07-30 were the same bug wearing different clothes:
#
#   1. smoke-3 point 3 computed its expected value with `find` over
#      /home/michael/probe/specs. The directory vanished when probe was merged
#      into sett. find on a missing dir returns nothing, so expected silently
#      became 0 — the correct answer began FAILING and a garbage answer began
#      PASSING. The check inverted.
#
#   2. SEAT.md — the law itself — told the model to verify its work with
#      `probe verify` at /home/michael/probe/probe. Every gym ran under a law
#      naming a tool that exits 127.
#
# Neither was caught by gate A (artifact absent) or gate C (artifact wrong),
# because neither is about the artifact. They are about the SPEC rotting away
# from the box underneath it.
#
# A path that stops existing does not announce itself. It just quietly changes
# what your checks mean. This makes it announce itself.
#
# usage: ./rot.sh          audit
#        ./rot.sh --quiet  exit code only (0 = clean)
set -uo pipefail
cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

QUIET=0; [ "${1:-}" = "--quiet" ] && QUIET=1
say() { [ "$QUIET" -eq 1 ] || printf '%s\n' "$*"; }

# Paths that are illustrative rather than asserted. Rule 5 of the law uses
# karte/x.json as an example of absolute-vs-relative; it is not a claim.
is_example() {
  case "$1" in
    */x.json|*/'<'*|*'$'*|*'*'*) return 0 ;;
  esac
  return 1
}

# Output dirs are created by a run; absent just means "not run yet".
is_output() { case "$1" in "$PWD"/out/*|/home/michael/SETT-repo/out/*) return 0 ;; esac; return 1; }

total=0; missing=0; skipped=0

audit_file() {
  local f="$1" shown=0
  # strip trailing punctuation that regex-grabs off prose and code
  grep -ohE '/home/[A-Za-z0-9_./-]+' "$f" 2>/dev/null \
    | sed 's/[`",);:.]*$//' | sort -u | while read -r p; do
      [ -n "$p" ] || continue
      [ "$p" = "/home" ] || [ "$p" = "/home/." ] && continue
      is_example "$p" && continue
      if [ ! -e "$p" ]; then
        is_output "$p" && continue
        printf '%s\t%s\n' "$f" "$p"
      fi
    done
}

say "== paths asserted by this repo =="
say

# Only files that ASSERT are audited: the law, the constitution, the specs.
# sett/gate-c.sh/rot.sh quote dead paths in their comments on purpose — that is
# history, not a claim about the box.
hits="$(for f in SEAT.md README.md specs/*.probe; do
          [ -f "$f" ] && audit_file "$f"
        done)"

allpaths="$(for f in SEAT.md README.md specs/*.probe; do
              [ -f "$f" ] && grep -ohE '/home/[A-Za-z0-9_./-]+' "$f" 2>/dev/null
            done | sed 's/[`",);:.]*$//' | sort -u | grep -v '^/home/\.$' | grep -v '^/home$')"
total="$(printf '%s' "$allpaths" | grep -c . || true)"

if [ -n "$hits" ]; then
  say "ROT — asserted but absent:"
  say
  printf '%s\n' "$hits" | while IFS=$'\t' read -r f p; do
    say "  $f"
    say "      $p"
  done
  missing="$(printf '%s\n' "$hits" | grep -c . || true)"
  say
  say "rot: $missing asserted path(s) do not exist  (of $total distinct)"
  exit 1
fi

say "clean: every asserted path exists  ($total distinct)"
exit 0
