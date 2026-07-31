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
cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/.."   # lib/ -> repo root

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

# Portability made rot BLIND. The moment specs said $CORPUS/kev/... instead of
# /home/michael/lab/..., this audit stopped seeing them: the count fell from 31
# paths to 13 and still reported "clean". An audit that silently narrows its own
# scope is worse than no audit, because it keeps printing the same reassuring
# word. So expand the variables before matching, exactly as sett does.
expand() { sed -e "s|\$SETT|$PWD|g" -e "s|\$CORPUS|$CORPUS_DIR|g"; }
CORPUS_DIR="${SETT_CORPUS:-/home/michael/lab/structured-data/raw}"

audit_file() {
  local f="$1" shown=0
  # strip trailing punctuation that regex-grabs off prose and code
  expand < "$f" 2>/dev/null | grep -ohE '/home/[A-Za-z0-9_./-]+' \
    | sed 's/[`",);:.]*$//' | sort -u | while read -r p; do
      [ -n "$p" ] || continue
      [ "$p" = "/home" ] || [ "$p" = "/home/." ] && continue
      is_example "$p" && continue
      grep -qxF "$p" rot.ignore 2>/dev/null && continue
      if [ ! -e "$p" ]; then
        is_output "$p" && continue
        printf '%s\t%s\n' "$f" "$p"
      fi
    done
}

# The docs that INSTRUCT — the law, the front page, the guided tour. These
# make claims about the box as it is now, so every path and verb in them must
# be live. docs/FLIGHT-*.md and docs/MORNING-*.md are deliberately excluded:
# they are dated records of what was true on a given night, and a record that
# names a path which has since been deleted is accurate, not rotten.
INSTRUCTING="SEAT.md README.md docs/SHOWCASE.md"

say "== paths asserted by this repo =="
say

# Only files that ASSERT are audited: the law, the constitution, the specs.
# sett/gate-c.sh/rot.sh quote dead paths in their comments on purpose — that is
# history, not a claim about the box.
hits="$(for f in $INSTRUCTING specs/*.probe; do
          [ -f "$f" ] && audit_file "$f"
        done)"

allpaths="$(for f in $INSTRUCTING specs/*.probe; do
              [ -f "$f" ] && expand < "$f" 2>/dev/null | grep -ohE '/home/[A-Za-z0-9_./-]+' 
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


# --- commands, not just paths -------------------------------------------
# RESULTS.md carried `probe sanity` / `probe run` / `probe verify` in its
# "Reproducing" section long after probe stopped existing. No path audit could
# see it: those are command names. A doc that tells you to run a verb that
# does not exist is rot in exactly the same way a dead path is.
verbs="$(sed -n '/^case "${1:-}" in/,/^esac/p' sett | grep -oE '^\s+[a-z|"-]+\)' | tr -d ' )' | tr '|' '\n' | tr -d '"' | grep -vE '^\*?$|^-')"
badcmd=0
while IFS= read -r line; do
  [ -n "$line" ] || continue
  f="${line%%:*}"; v="${line#*:}"
  printf '%s\n' "$verbs" | grep -qxF "$v" && continue
  say "  $f"
  say "      sett $v   — not a verb"
  badcmd=$((badcmd+1))
done < <(
  # Only CODE contexts: inline `sett verb` spans and lines inside ```sh
  # fences. Prose says things like "SETT is one program" and that is not a
  # command; reading it as one is how an audit earns a reputation for crying
  # wolf, which is how audits get ignored.
  for f in $INSTRUCTING RESULTS.md; do
    [ -f "$f" ] || continue
    grep -oE '`sett [a-z-]+' "$f" | sed 's/`//' | awk -v f="$f" '{print f ":" $2}'
    # only ```sh fences — README also has a plain fence listing the repo's
    # files, where the line "sett   the program." is a description, not a call
    awk '/^```sh/{c=1; next} /^```/{c=0; next} c && /^sett /{print FILENAME ":" $2}' "$f"
  done | sort -u
)

if [ "$badcmd" -gt 0 ]; then
  say
  say "rot: $badcmd command(s) named in docs are not verbs of sett"
  exit 1
fi

say "clean: every asserted path exists and every documented verb resolves  ($total paths, $(grep -cvE '^#|^$' rot.ignore 2>/dev/null || echo 0) allowlisted in rot.ignore)"
exit 0
