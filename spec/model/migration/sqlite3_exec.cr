require "./spec_for_migrations.cr"
require "sqlite3"
exec_migration("sqlite3://./db/sample.db")
