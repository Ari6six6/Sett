def table(rows):
    L=["| model | gym | score |","|---|---|---|"]
    for r in rows: L.append(f"| {r['model']} | {r['gym']} | {r['score']} |")
    return "\n".join(L)+"\n"
