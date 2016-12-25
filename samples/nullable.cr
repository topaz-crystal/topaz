require "../src/topaz"

##################
# Nullable Model #
##################
# You can specify nullable or not nullable for each column
# This is how to define it
class NullableModel < Topaz::Model
  columns(
    name: String,
    name_nullable: {type: String, nullable: true},
    name_not_nullable: {type: String, nullable: false},
  )
end

Topaz::Db.setup("sqlite3://./db/sample.db")
Topaz::Db.show_query(true)

# Setup table
NullableModel.drop_table
NullableModel.create_table

# You can create the model with null column
NullableModel.create("name0", nil, "name1")

n = NullableModel.find(1)
n.name_nullable.nil?
# => true
