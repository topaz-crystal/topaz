test:
	crystal spec ./spec/model/model_mysql.cr
	crystal spec ./spec/model/model_sqlite3.cr
	crystal spec ./spec/model/to_json.cr
sample:
	crystal run ./samples/model.cr
	crystal run ./samples/association.cr
	crystal run ./samples/to_json.cr

