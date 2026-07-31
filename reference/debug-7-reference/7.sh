#!/usr/bin/env bash
if [ $# -lt 1 ]; then echo "usage: 9.sh <kev.json>" >&2; exit 2; fi
python3 -c "
import json,sys
d=json.load(open(sys.argv[1]))
v=d['vulnerabilities']
print('total:',len(v))
print('ransomware:',sum(1 for x in v if x.get('knownRansomwareCampaignUse')=='Known'))
" "$1"
