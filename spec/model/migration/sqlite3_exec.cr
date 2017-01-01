require "./spec_for_migrations.cr"
exec_migration("sqlite3://./db/sample.db")
