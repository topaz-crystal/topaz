require "../src/topaz"

class Parent < Topaz::Model
  columns(
    {name: name, type: String}
  )

  has_many(
    {model: Child, as: childs, key: p_id}
  )
end

class Child < Topaz::Model
  columns(
    {name: p_id, type: Int64}
  )

  belongs_to(
    {model: Parent, as: parent, key: p_id}
  )
end

Topaz::Db.setup("sqlite3://./db/sample.db")
Child.drop_table
Child.create_table
Parent.drop_table
Parent.create_table

p = Parent.create("test")
c1 = Child.create(1.to_i64)
Child.create(1.to_i64)
Child.create(1.to_i64)

puts p.childs.size
puts c1.parent.name

p2 = Parent.create("test2")
puts p2.id
puts p2.childs.size
puts p.childs.size
