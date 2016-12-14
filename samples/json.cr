require "../src/topaz"

# In this sample, we have
# JsonParent
#  - JsonChild
#    - JsonToy
#      - JsonPart
#  - JsonPet

class JsonParent < Topaz::Model
  columns(name: String)
  has_many(
    childlen: {model: JsonChild, key: p_id},
    pets: {model: JsonPet, key: p_id}
  )
end

class JsonChild < Topaz::Model
  columns(
    age: Int64,
    p_id: Int64
  )
  has_many(toies: {model: JsonToy, key: c_id})
  belongs_to(parent: {model: JsonParent, key: p_id})
end

class JsonPet < Topaz::Model
  columns(p_id: Int64)
  belongs_to(parent: {model: JsonParent, key: p_id})
end

class JsonToy < Topaz::Model
  columns(
    name: String,
    price: Int64,
    c_id: Int64
  )
  has_many(parts: {model: JsonPart, key: t_id})
  belongs_to(child: {model: JsonChild, key: c_id})
end

class JsonPart < Topaz::Model
  columns(t_id: Int64)
  belongs_to(toy: {model: JsonToy, key: t_id})
end

Topaz::Db.setup("sqlite3://./db/sample.db")

JsonParent.drop_table
JsonChild.drop_table
JsonPet.drop_table
JsonToy.drop_table
JsonPart.drop_table

JsonParent.create_table
JsonChild.create_table
JsonPet.create_table
JsonToy.create_table
JsonPart.create_table

p = JsonParent.create("John")

c1 = JsonChild.create(12i64, p.id.to_i64)
c2 = JsonChild.create(15i64, p.id.to_i64)
c3 = JsonChild.create(23i64, p.id.to_i64)

p1 = JsonPet.create(p.id.to_i64)
p2 = JsonPet.create(p.id.to_i64)
p3 = JsonPet.create(p.id.to_i64)
p4 = JsonPet.create(p.id.to_i64)

t1 = JsonToy.create("abc", 10i64, c1.id.to_i64)
t2 = JsonToy.create("def", 12i64, c1.id.to_i64)
t3 = JsonToy.create("ghi", 15i64, c2.id.to_i64)

pt1 = JsonPart.create(t1.id.to_i64)
pt2 = JsonPart.create(t3.id.to_i64)
pt3 = JsonPart.create(t3.id.to_i64)
pt4 = JsonPart.create(t3.id.to_i64)

# The most simple case
# Print JsonParent as json
puts "p.json"
puts p.json
puts ""

# Print JsonParent as json including childlen and excepting id of JsonParent
puts "p.json({include: :childlen, except: :id})"
puts p.json({include: :childlen, except: :id})
puts ""

# Print JsonParent as json including childlen and pets with options
puts "p.json({include: {childlen: {except: [:id, :p_id]}, pets: nil} })"
puts p.json({include: {childlen: {except: [:id, :p_id]}, pets: nil}})
puts ""

# Print JsonParent as json including childlen, pets, toies and parts
puts "p.json({include: {childlen: {include: {toies: {include: :parts, only: :price} } }, pets: nil} })"
puts p.json({include: {childlen: {include: {toies: {include: :parts, only: :price}}}, pets: nil}})
puts ""
