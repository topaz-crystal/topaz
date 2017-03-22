require "./spec_for_migrations.cr"
require "mysql"
exec_migration("mysql://root@localhost/topaz_test")
