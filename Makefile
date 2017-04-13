all: spec sample

spec: basic migration

basic:
	crystal spec
	crystal spec ./spec/model/sqlite3.cr
	crystal spec ./spec/model/mysql.cr
	crystal spec ./spec/model/pg.cr

migration: mig-test-sqlite3 mig-test-mysql mig-test-pg

mig-test-sqlite3:
	crystal spec ./spec/model/migration/sqlite3_before.cr
	crystal spec ./spec/model/migration/sqlite3_exec.cr

mig-test-mysql:
	crystal spec ./spec/model/migration/mysql_before.cr
	crystal spec ./spec/model/migration/mysql_exec.cr

mig-test-pg:
	crystal spec ./spec/model/migration/pg_before.cr
	crystal spec ./spec/model/migration/pg_exec.cr

sample:
	crystal run ./samples/model.cr
	crystal run ./samples/association.cr
	crystal run ./samples/json.cr
	crystal run ./samples/transaction.cr
	crystal run ./samples/migration.cr
	crystal run ./samples/time.cr
	crystal run ./samples/nullable.cr
	crystal run ./samples/default.cr
