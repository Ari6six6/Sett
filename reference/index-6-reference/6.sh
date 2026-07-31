#!/usr/bin/env bash
set -euo pipefail
if [ $# -lt 2 ]; then echo "usage: 6.sh <bundle.sqlite> <ATT&CK-id>" >&2; exit 2; fi
python3 -c '
import sqlite3,sys
c=sqlite3.connect("file:%s?mode=ro"%sys.argv[1],uri=True)
q="select name from objects where external_id=? and name is not null"
for n in sorted({r[0] for r in c.execute(q,(sys.argv[2],))}): print(n)
' "$1" "$2"
