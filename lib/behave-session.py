#!/usr/bin/env python3
"""The apparatus, turned on the operator's own assistant.

`sett behave` measures the small model in the gym: did it read its input, did
it verify its artifact, did it one-shot the answer. Those numbers were only
ever computed for the model being graded.

But the frontier model driving the session leaves the same kind of record —
Claude Code writes a full JSONL transcript per session, every tool call
included — and it is doing the *operator's* work: writing the specs, writing
the checks, deciding what counts as done. That is the row this repo says a
model must never be trusted with.

So measure it the same way. The first run of this script reported:

    file-changing actions          124
      followed by a verification    85  (68%)
    read:write ratio              0.23

against `sett behave`'s 67% VERIFY for GLM-4.7-Flash in the gym. **Same rate.**
The 30B model being graded and the frontier model doing the grading checked
their own work about equally often, and the frontier model wrote four times
more than it read while working under a law whose first rule is "answer from
disk, not from your weights".

That is not a reason to distrust the output — every defect in this repo was
found, and the finding is in RESULTS.md either way. It is a reason to keep the
instruments, because vigilance did not scale and the instruments did.

usage: sett behave --session [FILE]
       FILE defaults to the most recently modified Claude Code transcript.
"""
import json, re, sys, glob, os, collections

VERIFY = re.compile(
    r'\bsett (selftest|rot|check|gate|lint|leak|score|prompts|status)\b'
    r'|bash -n|\bdiff\b|\bcmp\b|sha256sum|pytest|python3 -c')
MUTATORS = {'Edit', 'Write', 'NotebookEdit'}
LOOKAHEAD = 6   # tool calls after a change in which a verification still counts


def transcripts():
    pats = [os.path.expanduser('~/.claude/projects/*/*.jsonl')]
    out = []
    for p in pats:
        out += glob.glob(p)
    return sorted(out, key=os.path.getmtime, reverse=True)


def load(path):
    """Flatten the transcript into an ordered list of (tool_name, input)."""
    events, texts = [], []
    with open(path, errors='replace') as fh:
        for line in fh:
            try:
                d = json.loads(line)
            except Exception:
                continue
            msg = d.get('message') or {}
            content = msg.get('content')
            if not isinstance(content, list):
                continue
            for b in content:
                if not isinstance(b, dict):
                    continue
                if b.get('type') == 'tool_use':
                    events.append((b.get('name'), b.get('input') or {}))
                elif d.get('type') == 'assistant' and b.get('type') == 'text' and b.get('text'):
                    texts.append(b['text'])
    return events, texts


def main():
    args = [a for a in sys.argv[1:] if a != '--session']
    if args:
        path = args[0]
    else:
        found = transcripts()
        if not found:
            sys.exit('no Claude Code transcript found under ~/.claude/projects/')
        path = found[0]

    events, texts = load(path)
    if not events:
        sys.exit(f'no tool calls in {path}')

    mut = verified = 0
    unverified = []
    for i, (name, inp) in enumerate(events):
        if name not in MUTATORS:
            continue
        mut += 1
        for nm, ip in events[i + 1:i + 1 + LOOKAHEAD]:
            if nm == 'Bash' and VERIFY.search(ip.get('command', '') or ''):
                verified += 1
                break
        else:
            unverified.append(inp.get('file_path', '?'))

    kinds = collections.Counter(n for n, _ in events)
    reads = kinds.get('Read', 0)
    writes = sum(kinds.get(k, 0) for k in MUTATORS)
    blob = '\n'.join(texts)

    print(f'== session behaviour ==  {os.path.basename(path)}')
    print()
    print(f'  tool calls                   {len(events)}')
    print(f'  file-changing actions        {mut}')
    pct = 100 * verified // mut if mut else 0
    print(f'    followed by a verification {verified}  ({pct}%)')
    print(f'  read : write                 {reads}:{writes}  ({reads / max(writes,1):.2f})')
    print()
    print('  tool mix:', ', '.join(f'{k} {v}' for k, v in kinds.most_common(6)))
    print()
    corrections = len(re.findall(
        r"(?i)\b(I (just )?(wrote|invented|fabricated)|caught (and removed |a bug in )?my own"
        r"|that's on me|removing (them|it) now|should not have been written|too loose)", blob))
    caveats = len(re.findall(
        r'(?i)\b(confound|caveat|supported, not proven|cannot be evaluated|untestable'
        r'|not provable)', blob))
    print(f'  self-corrections in prose    {corrections}')
    print(f'  confounds/caveats stated     {caveats}')
    print(f'  words written                {len(blob.split()):,}')

    if unverified:
        print()
        print(f'  -- {len(unverified)} change(s) with no verification within '
              f'{LOOKAHEAD} tool calls --')
        for f, n in collections.Counter(unverified).most_common(8):
            print(f'     {n:3}x {f}')

    print()
    print('  Compare with `sett behave`, which reports VERIFY for the model')
    print('  being graded. If the two rates are close, the difference between')
    print('  the mouth doing the work and the mouth checking it is procedural,')
    print('  not cognitive — which is the entire argument for the instruments.')


if __name__ == '__main__':
    main()
