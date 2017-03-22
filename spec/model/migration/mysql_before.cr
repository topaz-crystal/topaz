require "./spec_for_migrations.cr"
require "mysql"
before_migration("mysql://root@localhost/topaz_test")
