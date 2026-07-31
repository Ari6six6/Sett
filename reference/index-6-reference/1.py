import sqlite3
def types(db_path):
    c = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
    return {t: n for t, n in c.execute("select type,count(*) from objects group by type")}
