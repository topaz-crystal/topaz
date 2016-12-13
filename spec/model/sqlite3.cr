require "../spec_helper"

# This spec needs real SQLite3 db with table 'topaz'.
# `crystal spec` doesn't execute this.

class AllTypes < Topaz::Model
  columns(
    {name: type_string, type: String},
    {name: type_integer, type: Int32},
    {name: type_float, type: Float32},
    # Pimary key is not supported since it's already used as id.
    {name: type_double, type: Float64},
  )
end

class MockModel < Topaz::Model
  columns(
    {name: name, type: String},
    {name: age, type: Int32},
  )
end

class JsonParent < Topaz::Model
  columns({name: name, type: String})
  has_many(
    {model: JsonChild, as: childlen, key: p_id},
    {model: JsonPet, as: pets, key: p_id}
  )
end

class JsonChild < Topaz::Model
  columns(
    {name: age, type: Int32},
    {name: p_id, type: Int32}
  )
  has_many({model: JsonToy, as: toies, key: c_id})
  belongs_to({model: JsonParent, as: parent, key: p_id})
end

class JsonPet < Topaz::Model
  columns({name: p_id, type: Int32})
  belongs_to({model: JsonParent, as: parent, key: p_id})
end

class JsonToy < Topaz::Model
  columns(
    {name: name, type: String},
    {name: price, type: Int32},
    {name: c_id, type: Int32}
  )
  has_many({model: JsonPart, as: parts, key: t_id})
  belongs_to({model: JsonChild, as: child, key: c_id})
end

class JsonPart < Topaz::Model
  columns({name: t_id, type: Int32})
  belongs_to({model: JsonToy, as: toy, key: t_id})
end

Spec.before_each do
  Topaz::Db.setup("sqlite3://./db/sample.db")
  MockModel.create_table
  AllTypes.create_table
  JsonParent.create_table
  JsonChild.create_table
  JsonPet.create_table
  JsonToy.create_table
  JsonPart.create_table
end

Spec.after_each do
  MockModel.drop_table
  AllTypes.drop_table
  JsonParent.drop_table
  JsonChild.drop_table
  JsonPet.drop_table
  JsonToy.drop_table
  JsonPart.drop_table
  Topaz::Db.close
end

describe Topaz do
  it "Using SQLite3" do
    AllTypes.create("test", 10, 12.0f32, 10.0)
    AllTypes.select.size.should eq(1)
    10.times do |i|
      MockModel.create("mock#{i}", i)
    end
    MockModel.find(1).name.should eq("mock0")
    MockModel.where("name = 'mock0'").select.size.should eq(1)
    MockModel.order("age", "desc").range(1, 3).select.first.name.should eq("mock8")
    m = MockModel.find(1)
    m.name = "mock_updated"
    m.update
    MockModel.find(1).name.should eq("mock_updated")
    m2 = MockModel.find(2)
    m2.update({name: "mock_updated2"})
    MockModel.find(2).name.should eq("mock_updated2")
    MockModel.update({name: "mock_udpated_all"})
    MockModel.where("name = 'mock_udpated_all'").select.size.should eq(10)
    MockModel.find(1).delete
    MockModel.select.size.should eq(9)
    MockModel.delete
    MockModel.select.size.should eq(0)
    p = JsonParent.create("John")
    c1 = JsonChild.create(12, p.id)
    c2 = JsonChild.create(15, p.id)
    c3 = JsonChild.create(23, p.id)
    pe1 = JsonPet.create(p.id)
    pe2 = JsonPet.create(p.id)
    pe3 = JsonPet.create(p.id)
    pe4 = JsonPet.create(p.id)
    t1 = JsonToy.create("abc", 10i32, c1.id)
    t2 = JsonToy.create("def", 12i32, c1.id)
    t3 = JsonToy.create("ghi", 15i32, c2.id)
    pa1 = JsonPart.create(t1.id)
    pa2 = JsonPart.create(t3.id)
    pa3 = JsonPart.create(t3.id)
    pa4 = JsonPart.create(t3.id)

    p.childlen.size.should eq 3
    p.pets.size.should eq 4
    c1.toies.size.should eq 2
    c2.toies.size.should eq 1
    t1.parts.size.should eq 1
    t3.parts.size.should eq 3

    p = JsonParent.select.first
    p.json.should eq "{\"id\": 1, \"name\": \"John\"}"
    p.json({include: :childlen, except: :id}).should eq "{\"name\": \"John\", \"childlen\": [{\"id\": 1, \"age\": 12, \"p_id\": 1}, {\"id\": 2, \"age\": 15, \"p_id\": 1}, {\"id\": 3, \"age\": 23, \"p_id\": 1}]}"
    p.json({include: {childlen: {except: [:id, :p_id]}, pets: nil}}).should eq "{\"id\": 1, \"name\": \"John\", \"childlen\": [{\"age\": 12}, {\"age\": 15}, {\"age\": 23}], \"pets\": [{\"id\": 1, \"p_id\": 1}, {\"id\": 2, \"p_id\": 1}, {\"id\": 3, \"p_id\": 1}, {\"id\": 4, \"p_id\": 1}]}"
    p.json({include: {childlen: {include: {toies: {include: :parts, only: :price}}}, pets: nil}}).should eq "{\"id\": 1, \"name\": \"John\", \"childlen\": [{\"id\": 1, \"age\": 12, \"p_id\": 1, \"toies\": [{\"price\": 10, \"parts\": [{\"id\": 1, \"t_id\": 1}]}, {\"price\": 12, \"parts\": []}]}, {\"id\": 2, \"age\": 15, \"p_id\": 1, \"toies\": [{\"price\": 15, \"parts\": [{\"id\": 2, \"t_id\": 3}, {\"id\": 3, \"t_id\": 3}, {\"id\": 4, \"t_id\": 3}]}]}, {\"id\": 3, \"age\": 23, \"p_id\": 1, \"toies\": []}], \"pets\": [{\"id\": 1, \"p_id\": 1}, {\"id\": 2, \"p_id\": 1}, {\"id\": 3, \"p_id\": 1}, {\"id\": 4, \"p_id\": 1}]}"
  end
end
