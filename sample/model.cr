require "../src/topaz"

## TODO
## SQLite support

# This is a sample for Topaz::Model
# You can define attributes for you model
class SampleModel < Topaz::Model
  # Attributes
  attrs(
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

# Show a log
Topaz::Logger.i("This is a sample code for Topaz, this code print nothing except this message.")

# Setup db
Topaz.setup("mysql://root@localhost/topaz")

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

# You can specified id to find a model
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

# You can update columns by using Hash
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

# You can define relations for each model
# For now, let me define 2 models
class SampleParent < Topaz::Model
  
  attrs(
    {name: name, type: String}
  )

  # This meant that SampleParent has multiple SampleChild
  # You can access it as childs by select them from parent_id
  has({model: SampleChild, as: childs, id: parent_id})
end

class SampleChild < Topaz::Model
  attrs(
    {name: name, type: String},
    {name: parent_id, type: Int32}
  )

  # This meant that SampleChild belongs to a SampleParent
  # You can access it as parent by finding by parent_id
  belongs({model: SampleParent, as: parent, id: parent_id})
end

# Setup tables
SampleParent.drop_table
SampleParent.create_table
SampleChild.drop_table
SampleChild.create_table

# Let me create a parent
p = SampleParent.create("Parent")

# Here we create 3 childs belong to the parent
child1 = SampleChild.create("Child1", p.id)
child2 = SampleChild.create("Child2", p.id)
child3 = SampleChild.create("Child3", p.id)

# Select all childs
p.childs.size
# => 3

# Find a parent
child1.parent.name
# => Parent
