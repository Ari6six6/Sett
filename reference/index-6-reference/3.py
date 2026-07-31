import sqlite3
def neighbors(db_path, object_id):
    c = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
    out = sorted({r[0] for r in c.execute("select target_ref from relationships where source_ref=?", (object_id,))})
    inc = sorted({r[0] for r in c.execute("select source_ref from relationships where target_ref=?", (object_id,))})
    return {"out": out, "in": inc}
