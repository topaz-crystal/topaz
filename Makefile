
all: test sample

test:
	crystal spec ./spec/model/sqlite3.cr
	crystal spec ./spec/model/mysql.cr
	crystal spec ./spec/model/pg.cr
sample:
	crystal run ./samples/model.cr
	crystal run ./samples/association.cr
	crystal run ./samples/json.cr
	crystal run ./samples/readme.cr
