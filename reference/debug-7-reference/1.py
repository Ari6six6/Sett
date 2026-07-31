def latest(path):
    out={}
    for line in open(path):
        p=line.rstrip("\n").split("\t")
        if len(p)>=3 and p[1]: out[p[1]]=p[2]
    return out
