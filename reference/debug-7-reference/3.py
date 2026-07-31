def summary(path):
    last={}
    for line in open(path):
        p=line.rstrip("\n").split("\t")
        if len(p)>=3 and p[1]: last[p[1]]=p[2]
    c={"pass":0,"fail":0,"error":0}
    for v in last.values():
        k=v.strip().lower()
        if k in c: c[k]+=1
    return c
