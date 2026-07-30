def lint(path):
    missing=[]; cur=None; has=False
    for line in open(path):
        if line.startswith("## "):
            if cur is not None and not has: missing.append(cur)
            cur=line[3:].split()[0]; has=False
        elif line.startswith("check:"): has=True
    if cur is not None and not has: missing.append(cur)
    return missing
