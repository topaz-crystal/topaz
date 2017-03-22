require "./spec_for_migrations.cr"
require "sqlite3"
before_migration("sqlite3://./db/sample.db")
