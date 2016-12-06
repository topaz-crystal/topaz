require "../spec_helper"

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

describe Topaz do
  Spec.before_each do
    Topaz::Db.setup("sqlite3://./db/sample.db")
    JsonParent.create_table
    JsonChild.create_table
    JsonPet.create_table
    JsonToy.create_table
    JsonPart.create_table
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
  end

  Spec.after_each do
    JsonParent.drop_table
    JsonChild.drop_table
    JsonPet.drop_table
    JsonToy.drop_table
    JsonPart.drop_table
    Topaz::Db.clean
  end

  it "p.to_json" do
    p = JsonParent.select.first
    p.to_json.should eq "{\"id\": 1, \"name\": \"John\"}"
  end

  it "p.to_json({include: :childlen, except: :id})" do
    p = JsonParent.select.first
    p.to_json({include: :childlen, except: :id}).should eq "{\"name\": \"John\", \"childlen\": [{\"id\": 1, \"age\": 12, \"p_id\": 1}, {\"id\": 2, \"age\": 15, \"p_id\": 1}, {\"id\": 3, \"age\": 23, \"p_id\": 1}]}"
  end

  it "p.to_json({include: {childlen: {except: [:id, :p_id]}, pets: nil} })" do
    p = JsonParent.select.first
    p.to_json({include: {childlen: {except: [:id, :p_id]}, pets: nil}}).should eq "{\"id\": 1, \"name\": \"John\", \"childlen\": [{\"age\": 12}, {\"age\": 15}, {\"age\": 23}], \"pets\": [{\"id\": 1, \"p_id\": 1}, {\"id\": 2, \"p_id\": 1}, {\"id\": 3, \"p_id\": 1}, {\"id\": 4, \"p_id\": 1}]}"
  end

  it "p.to_json({include: {childlen: {include: {toies: {include: :parts, only: :price} } }, pets: nil} })" do
    p = JsonParent.select.first
    p.to_json({include: {childlen: {include: {toies: {include: :parts, only: :price}}}, pets: nil}}).should eq "{\"id\": 1, \"name\": \"John\", \"childlen\": [{\"id\": 1, \"age\": 12, \"p_id\": 1, \"toies\": [{\"price\": 10, \"parts\": [{\"id\": 1, \"t_id\": 1}]}, {\"price\": 12, \"parts\": []}]}, {\"id\": 2, \"age\": 15, \"p_id\": 1, \"toies\": [{\"price\": 15, \"parts\": [{\"id\": 2, \"t_id\": 3}, {\"id\": 3, \"t_id\": 3}, {\"id\": 4, \"t_id\": 3}]}]}, {\"id\": 3, \"age\": 23, \"p_id\": 1, \"toies\": []}], \"pets\": [{\"id\": 1, \"p_id\": 1}, {\"id\": 2, \"p_id\": 1}, {\"id\": 3, \"p_id\": 1}, {\"id\": 4, \"p_id\": 1}]}"
  end
end
