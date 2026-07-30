#!/usr/bin/env bash
# work — a durable tmux workbench for SETT.
#
# Built because three background runs died to harness teardown today, one of
# them unnoticed for 33 minutes while I reported it as "still running".
# A tmux session outlives the agent, the terminal, and the SSH connection.
#
#   ./work.sh            create or attach
#   ./work.sh run "cmd"  queue a command into the runner pane, logged
#   ./work.sh log        tail the runner log
#   ./work.sh status     what is alive
set -uo pipefail
cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"
S=sett
LOG=runs/work.log

case "${1:-attach}" in
  attach|"")
    if tmux has-session -t "$S" 2>/dev/null; then exec tmux attach -t "$S"; fi
    tmux new-session -d -s "$S" -n runner -c "$PWD"
    tmux new-window  -t "$S" -n watch  -c "$PWD"
    tmux send-keys   -t "$S:watch" 'watch -n 30 "./sett score 2>/dev/null | tail -20; echo; tail -5 runs/work.log"' C-m
    tmux new-window  -t "$S" -n shell  -c "$PWD"
    tmux select-window -t "$S:runner"
    echo "session '$S' created: runner | watch | shell"
    echo "attach with:  tmux attach -t $S"
    ;;
  run)
    shift; [ $# -gt 0 ] || { echo "usage: work.sh run \"<cmd>\""; exit 2; }
    tmux has-session -t "$S" 2>/dev/null || { "$0" attach >/dev/null; }
    mkdir -p runs
    # -l sends the string literally; the redirection is appended so every
    # queued command is logged with a timestamp, unattended.
    tmux send-keys -t "$S:runner" -l "{ echo \"[\$(date +%H:%M:%S)] \$ $*\"; $*; echo \"[\$(date +%H:%M:%S)] exit=\$?\"; } 2>&1 | tee -a $LOG"
    tmux send-keys -t "$S:runner" C-m
    echo "queued -> $S:runner   (./work.sh log to follow)"
    ;;
  log)   tail -f "$LOG" ;;
  status)
    tmux has-session -t "$S" 2>/dev/null && tmux list-windows -t "$S" || echo "no session"
    echo "--- endpoint ---"; ./sett body 2>/dev/null | head -1
    ;;
  kill) tmux kill-session -t "$S" 2>/dev/null && echo "killed" ;;
  *) echo "usage: work.sh [attach|run \"cmd\"|log|status|kill]"; exit 2 ;;
esac
