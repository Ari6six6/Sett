import json,collections
def type_histogram(path,n):
    o=json.load(open(path))["objects"]
    return collections.Counter(x["type"] for x in o).most_common(n)
