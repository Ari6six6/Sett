def merge(intervals):
    if not intervals: return []
    s=sorted(intervals, key=lambda x: x[0]); out=[list(s[0])]
    for a,b in s[1:]:
        if a<=out[-1][1]: out[-1][1]=max(out[-1][1],b)
        else: out.append([a,b])
    return out
