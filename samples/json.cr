require "../src/topaz"
require "sqlite3"

###############
# Json Sample #
###############

# In this sample, we have
# JsonParent
#  - JsonChild

class JsonParent < Topaz::Model
  columns(name: String)
  has_many(
    children: {model: JsonChild, key: p_id},
  )
end

class JsonChild < Topaz::Model
  columns(
    age: Int64,
    p_id: Int64
  )
  belongs_to(parent: {model: JsonParent, key: p_id})
end

Topaz::Db.setup("sqlite3://./db/sample.db")

JsonParent.drop_table
JsonChild.drop_table

JsonParent.create_table
JsonChild.create_table

p = JsonParent.create("John")

c1 = JsonChild.create(12i64, p.id.to_i64)
c2 = JsonChild.create(15i64, p.id.to_i64)
c3 = JsonChild.create(23i64, p.id.to_i64)

# output of created_at and udpated_at columns are just examples
p.to_json
# => {"id":1,"name":"John","created_at":"2016-12-26T02:47:34+0900","updated_at":"2016-12-26T02:47:34+0900"}
c1.to_json
# => {"id":1,"age":12,"p_id":1,"created_at":"2016-12-26T02:47:34+0900","updated_at":"2016-12-26T02:47:34+0900"}
c2.to_json
# => {"id":2,"age":15,"p_id":1,"created_at":"2016-12-26T02:47:34+0900","updated_at":"2016-12-26T02:47:34+0900"}
c3.to_json
# => {"id":3,"age":23,"p_id":1,"created_at":"2016-12-26T02:47:34+0900","updated_at":"2016-12-26T02:47:34+0900"}

# id is not nullable
# id == -1 meant that the instance is not saved
c4 = JsonParent.from_json("{\"id\": -1, \"name\": \"Who\"}")
c4.to_json
# => {"id":-1,"name":"Who"}
c4.save
c4.to_json
# => {"id":2,"name":"Who","created_at":"2016-12-26T02:47:34+0900","updated_at":"2016-12-26T02:47:34+0900"}
