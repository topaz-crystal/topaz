require "../src/topaz"
require "sqlite3"

###################
# Nullable Column #
###################
# You can specify nullable or not nullable for each column
# The default value of nullable column is `nil`.
# You have to define NOT nullable columns first.
# See a sample at `sample/default.cr` for details.
class NullableModel < Topaz::Model
  columns(
    name: String,
    name_not_nullable: {type: String, nullable: false},
    name_nullable: {type: String, nullable: true},
    time_nullable: {type: Time, nullable: true}
  )
end

Topaz::Db.setup("sqlite3://./db/sample.db")

# Setup table
NullableModel.drop_table
NullableModel.create_table

# You can create the model with null column
NullableModel.create("name0", "name1", nil, nil)

# Or you can omit the nil column (The value will be nil)
NullableModel.create("name0", "name1")

n = NullableModel.find(1)
n.name_nullable.nil?
# => true
