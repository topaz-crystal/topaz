
# Running `crystal spec` for each db types

test:
	crystal spec ./spec/model/model_mysql.cr
	crystal spec ./spec/model/model_sqlite3.cr
	crystal run ./sample/model.cr
	crystal run ./sample/association.cr

