
all: test sample

test:
	crystal spec
	crystal spec ./spec/model/sqlite3.cr
	crystal spec ./spec/model/mysql.cr
	crystal spec ./spec/model/pg.cr
sample:
	crystal run ./samples/model.cr
	crystal run ./samples/association.cr
	crystal run ./samples/json.cr
	crystal run ./samples/transaction.cr
	crystal run ./samples/migration.cr
	crystal run ./samples/time.cr
	crystal run ./samples/nullable.cr
