require "../src/topaz"

Topaz::Db.setup("mysql://root@localhost/topaz") # For MySQL

class SampleParent < Topaz::Model
  columns # Empty columns
  has_many(childs: {model: SampleChild, key: parent_id})
end

class SampleChild < Topaz::Model
  columns( # Define foreign key
parent_id: Int32
  )
  belongs_to(parent: {model: SampleParent, key: parent_id})
end

SampleParent.drop_table
SampleParent.create_table
SampleChild.drop_table
SampleChild.create_table

p = SampleParent.create

child1 = SampleChild.create(p.id)
child2 = SampleChild.create(p.id)
child3 = SampleChild.create(p.id)

p.childs.size
# => 3

child1.parent.id
# => 1

p.json({include: :childs})
# => {"id": 1, "childs": [{"id": 1, "parent_id": 1}, {"id": 2, "parent_id": 1}, {"id": 3, "parent_id": 1}]}
