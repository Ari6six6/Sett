import sqlite3
def by_external_id(db_path, ext_id):
    c = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
    q = "select name from objects where external_id=? and name is not null"
    return sorted({r[0] for r in c.execute(q, (ext_id,))})
