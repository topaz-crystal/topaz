require "../src/topaz"

######################
# Association Sample #
######################

# You can define associations for each model
# For now, let me define 2 models
class SampleParent < Topaz::Model
  columns(
    {name: name, type: String},
    # This meant that SampleParent has multiple SampleChild
    # You can access it as childs where parent_id of the childs equals to my id
    {has: SampleChild, as: childs}
  )
end

class SampleChild < Topaz::Model
  columns(
    {name: name, type: String},
    # This meant that SampleChild belongs to a SampleParent
    # You can access SampleParent as parent where id of it equals to parent_id
    {name: parent_id, type: Int32, belongs: SampleParent, as: parent}
  )
end

# Setup logger level
# For now, disable debug level logs and queries
Topaz::Logger.debug(false)
Topaz::Logger.show_query(false)

# Setup db
Topaz.setup("mysql://root@localhost/topaz")

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

