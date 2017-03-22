require "./spec_for_migrations.cr"
require "pg"
exec_migration("postgres://root@localhost/topaz_test")
