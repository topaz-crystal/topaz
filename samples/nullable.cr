require "../src/topaz"
require "sqlite3"

###################
# Nullable Column #
###################
# You can specify nullable or not nullable for each column
# This is how to define it
class NullableModel < Topaz::Model
  columns(
    name: String,
    name_nullable: {type: String, nullable: true},
    name_not_nullable: {type: String, nullable: false},
    time_nullable: {type: Time, nullable: true}
  )
end

Topaz::Db.setup("sqlite3://./db/sample.db")

# Setup table
NullableModel.drop_table
NullableModel.create_table

# You can create the model with null column
NullableModel.create("name0", nil, "name1", nil)

n = NullableModel.find(1)
n.name_nullable.nil?
# => true
