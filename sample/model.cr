require "../src/topaz"

################
# Model Sample #
################

# This is a sample for Topaz::Model
# You can define columns for your model
class SampleModel < Topaz::Model
  # Basically, each column needs 'name' and 'type' keys.
  # 'name' key is a column names which is accessible from code
  # For example, when you define an column {name: ok} for MyModel, you can access it like
  # ```
  # m = MyModel("ok_key")
  # m.ok
  # => "ok_key"
  # ```
  # 'type' key is a column type for defined column
  # Currently, String, Int32, Float32 and Float64 are supported
  columns(
    {name: name, type: String},
    {name: age, type: Int32},
    {name: score, type: Int32},
    {name: time, type: Float64},
    {name: uid, type: Int32, primary: true}, # uid is primary
  )
end

# Setup logger level
# For now, disable debug level logs and queries
Topaz::Logger.debug(false)
Topaz::Logger.show_query(false)

# Setup db
Topaz::Db.setup("mysql://root@localhost/topaz")

# Setup tables
# You can create or drop a table as follows
# These calls should be defined in other files such as migration.cr
SampleModel.drop_table
SampleModel.create_table

# Here, we create 7 models.
aaa = SampleModel.create("AAA", 25, 10, 20.0, 2)
bbb = SampleModel.create("BBB", 26, 12, 32.0, 3)
ccc = SampleModel.create("CCC", 25, 18, 40.0, 4)
ddd = SampleModel.create("DDD", 27, 11, 41.0, 5)
eee = SampleModel.create("EEE", 24, 11, 42.0, 6)
fff = SampleModel.create("FFF", 22, 15, 45.0, 7)
ggg = SampleModel.create("GGG", 25, 14, 18.0, 8)

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
SampleModel.order("score").range(1, 3).select.first.time
# => 41.0

# Update name from AAA to AAA+
aaa.name = "AAA+"
aaa.update
aaa.name
# => AAA+

# You can update columns by using Hash (NamedTuple actually)
bbb.update({name: "BBB+"})
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
