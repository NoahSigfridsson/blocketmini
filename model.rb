
def connect_db()
    db = SQLite3::Database.new("db/blocketmini.db")
    db.results_as_hash = true
    return db
end