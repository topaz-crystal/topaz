require "../src/topaz"

Topaz::Db.setup("sqlite3://./db/sample.db")

# Migration is useful in the following case
# 1. You already define and create a model and columns
# 2. You've added or removed columns from the defined model
# 3. You want to keep data of remaining columns

# We assume the case that we've already defined
