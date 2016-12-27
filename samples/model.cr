require "../src/topaz"

################
# Model Sample #
################

# This is a sample for Topaz::Model using SQLite3 as db
# You can define columns for your model as follows
class SampleModel < Topaz::Model
  # Basically, each column needs 'name' and 'type'.
  # Currently, String, Int32, Float32 and Float64 are supported
  # In this sample, we use SQLite3 as database.
  columns(
    name: String,
    age: Int64,
    score: Float64,
  )
end

# Setup db
Topaz::Db.setup("sqlite3://./db/sample.db")

# Setup tables
# You can create or drop a table as follows
# Actually, these calls should be defined in other files such as migration.cr
SampleModel.drop_table
SampleModel.create_table

# Here, we create 7 models.
aaa = SampleModel.create("AAA", 25.to_i64, 20.0)
bbb = SampleModel.create("BBB", 26.to_i64, 32.0)
ccc = SampleModel.create("CCC", 25.to_i64, 40.0)
ddd = SampleModel.create("DDD", 27.to_i64, 41.0)
eee = SampleModel.create("EEE", 24.to_i64, 42.0)
fff = SampleModel.create("FFF", 22.to_i64, 45.0)
ggg = SampleModel.create("GGG", 25.to_i64, 18.0)

# Select all models we created
SampleModel.select.size
# => 7

# You can specify id to find a model
SampleModel.find(1).name
# => AAA

# Select models where it's age equals 25
SampleModel.where("age = 25").select.size
# => 3

# Note that when you specify string as searched query, single quates are needed
SampleModel.where("name = 'AAA'").select.size
# => 1

# Select samples ordered by 'score' and set offset = 1 and limit = 3
SampleModel.order("score").range(1, 3).select.first.name
# => AAA

# Update name from AAA to AAA+
aaa.name = "AAA+"
aaa.update
aaa.name
# => AAA+

# You can update columns by using Hash (NamedTuple actually)
bbb.update(name: "BBB+")
bbb.name
# => BBB+

# Delete a model
ggg.delete
SampleModel.select.size
# => 6

# Delete all models
SampleModel.delete
SampleModel.select.size
# => 0
