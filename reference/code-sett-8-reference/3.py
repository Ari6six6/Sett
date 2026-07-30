def points(path):
    out=[]
    for line in open(path):
        if line.startswith("## "):
            rest=line[3:].strip().split(None,1)
            out.append((rest[0], rest[1] if len(rest)>1 else ""))
    return out
