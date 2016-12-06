test:
	crystal spec ./spec/model/model_spec.cr
	crystal spec ./spec/model/model_spec_for_mysql.cr
sample:
	crystal run ./samples/model.cr
	crystal run ./samples/association.cr
	crystal run ./samples/to_json.cr

