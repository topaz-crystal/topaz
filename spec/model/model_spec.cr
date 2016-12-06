require "../spec_helper"

## This spec creates real SQLite3 db into ./db/data.db
## `crystal spec` executes this.

class AllTypes < Topaz::Model
  columns(
    {name: type_string, type: String},
    {name: type_integer, type: Int64},
    {name: type_double, type: Float64},
  )
end

class MockModel < Topaz::Model
  columns(
    {name: name, type: String},
    {name: age, type: Int64},
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
    {name: age, type: Int64},
    {name: p_id, type: Int64}
  )
  has_many({model: JsonToy, as: toies, key: c_id})
  belongs_to({model: JsonParent, as: parent, key: p_id})
end

class JsonPet < Topaz::Model
  columns({name: p_id, type: Int64})
  belongs_to({model: JsonParent, as: parent, key: p_id})
end

class JsonToy < Topaz::Model
  columns(
    {name: name, type: String},
    {name: price, type: Int64},
    {name: c_id, type: Int64}
  )
  has_many({model: JsonPart, as: parts, key: t_id})
  belongs_to({model: JsonChild, as: child, key: c_id})
end

class JsonPart < Topaz::Model
  columns({name: t_id, type: Int64})
  belongs_to({model: JsonToy, as: toy, key: t_id})
end

Spec.before_each do
  Topaz::Db.setup("sqlite3://./db/data.db")
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
  Topaz::Db.clean
end

describe Topaz do
  
  describe "Using SQLite3" do
    
    it "All data types" do
      
      AllTypes.create("test", 10.to_i64, 10.0)
      AllTypes.select.size.should eq(1)
      
      10.times do |i|
        MockModel.create("mock#{i}", i.to_i64)
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
      
      c1 = JsonChild.create(12i64, p.id.to_i64)
      c2 = JsonChild.create(15i64, p.id.to_i64)
      c3 = JsonChild.create(23i64, p.id.to_i64)
      
      pe1 = JsonPet.create(p.id.to_i64)
      pe2 = JsonPet.create(p.id.to_i64)
      pe3 = JsonPet.create(p.id.to_i64)
      pe4 = JsonPet.create(p.id.to_i64)
      
      t1 = JsonToy.create("abc", 10i64, c1.id.to_i64)
      t2 = JsonToy.create("def", 12i64, c1.id.to_i64)
      t3 = JsonToy.create("ghi", 15i64, c2.id.to_i64)
      
      pa1 = JsonPart.create(t1.id.to_i64)
      pa2 = JsonPart.create(t3.id.to_i64)
      pa3 = JsonPart.create(t3.id.to_i64)
      pa4 = JsonPart.create(t3.id.to_i64)

      p = JsonParent.select.first
      p.to_json.should eq "{\"id\": 1, \"name\": \"John\"}"
      
      p = JsonParent.select.first
      p.to_json({include: :childlen, except: :id}).should eq "{\"name\": \"John\", \"childlen\": [{\"id\": 1, \"age\": 12, \"p_id\": 1}, {\"id\": 2, \"age\": 15, \"p_id\": 1}, {\"id\": 3, \"age\": 23, \"p_id\": 1}]}"
      
      p = JsonParent.select.first
      p.to_json({include: {childlen: {except: [:id, :p_id]}, pets: nil}}).should eq "{\"id\": 1, \"name\": \"John\", \"childlen\": [{\"age\": 12}, {\"age\": 15}, {\"age\": 23}], \"pets\": [{\"id\": 1, \"p_id\": 1}, {\"id\": 2, \"p_id\": 1}, {\"id\": 3, \"p_id\": 1}, {\"id\": 4, \"p_id\": 1}]}"
      
      p = JsonParent.select.first
      p.to_json({include: {childlen: {include: {toies: {include: :parts, only: :price}}}, pets: nil}}).should eq "{\"id\": 1, \"name\": \"John\", \"childlen\": [{\"id\": 1, \"age\": 12, \"p_id\": 1, \"toies\": [{\"price\": 10, \"parts\": [{\"id\": 1, \"t_id\": 1}]}, {\"price\": 12, \"parts\": []}]}, {\"id\": 2, \"age\": 15, \"p_id\": 1, \"toies\": [{\"price\": 15, \"parts\": [{\"id\": 2, \"t_id\": 3}, {\"id\": 3, \"t_id\": 3}, {\"id\": 4, \"t_id\": 3}]}]}, {\"id\": 3, \"age\": 23, \"p_id\": 1, \"toies\": []}], \"pets\": [{\"id\": 1, \"p_id\": 1}, {\"id\": 2, \"p_id\": 1}, {\"id\": 3, \"p_id\": 1}, {\"id\": 4, \"p_id\": 1}]}"      
    end
  end
end
