require "../spec_helper"
require "./models"

macro select_db(db)

  Topaz::Db.setup("{{db.id}}")

  describe Topaz do

    it "Empty column" do
      EmptyColumn.drop_table
      EmptyColumn.create_table
      EmptyColumn.create
      EmptyColumn.select.size.should eq(1)
    end

    it "Check all types" do
      AllTypes.drop_table
      AllTypes.create_table
      AllTypes.create("test", 10, 12.0f32, 10.0)
      AllTypes.select.size.should eq(1)
    end

    it "Search models" do
      SearchedModel.drop_table
      SearchedModel.create_table
      10.times do |i|
        SearchedModel.create("mock#{i}", i)
      end
      SearchedModel.find(1).name.should eq("mock0")
      SearchedModel.where("name = 'mock0'").select.size.should eq(1)
      SearchedModel.order("age", "desc").range(1, 3).select.first.name.should eq("mock8")
    end

    it "Update models" do
      UpdatedModel.drop_table
      UpdatedModel.create_table
      10.times do |i|
        UpdatedModel.create("mock#{i}", i)
      end
      m = UpdatedModel.find(1)
      m.name = "mock_updated"
      m.update
      UpdatedModel.find(1).name.should eq("mock_updated")
      UpdatedModel.find(2).name.should eq("mock1")
      m2 = UpdatedModel.find(2)
      m2.update(name: "mock_updated2")
      UpdatedModel.find(2).name.should eq("mock_updated2")
      UpdatedModel.update(name: "mock_udpated_all")
      UpdatedModel.where("name = 'mock_udpated_all'").select.size.should eq(10)
    end

    it "Delete models" do
      DeletedModel.drop_table
      DeletedModel.create_table
      10.times do |i|
        DeletedModel.create("mock#{i}", i)
      end
      DeletedModel.find(1).delete
      DeletedModel.select.size.should eq(9)
      DeletedModel.delete
      DeletedModel.select.size.should eq(0)
    end

    it "Generate json" do
      
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

    it "Create in transaction" do
      TransactionModel.drop_table
      TransactionModel.create_table
      
      Topaz::Db.shared.transaction do |tx|
        TransactionModel.in(tx).select.size.should eq(0)
        t0 = TransactionModel.in(tx).create("name0")
        t1 = TransactionModel.new("name1").in(tx).save
        t0.name.should eq("name0")
        t1.name.should eq("name1")
        TransactionModel.in(tx).select.size.should eq(2)
      end

      TransactionModel.select.size.should eq(2)
    end

    it "Update in transaction" do
      TransactionModel.drop_table
      TransactionModel.create_table

      Topaz::Db.shared.transaction do |tx|
        5.times do |i|
          TransactionModel.in(tx).create("name#{i}")
        end
        t0 = TransactionModel.in(tx).find(1)
        t0.name.should eq("name0")
        t0.name = "name0 updated"
        t0.in(tx).update
        TransactionModel.in(tx).find(1).name.should eq("name0 updated")
        TransactionModel.in(tx).find(2).name.should eq("name1")
        TransactionModel.in(tx).update(name: "all updated")
        TransactionModel.in(tx).select.each do |tm|
          tm.name.should eq("all updated")
        end
      end
    end

    it "Delete in transaction" do
      TransactionModel.drop_table
      TransactionModel.create_table

      Topaz::Db.shared.transaction do |tx|
        5.times do |i|
          TransactionModel.in(tx).create("name#{i}")
        end
        TransactionModel.in(tx).select.size.should eq(5)
        t0 = TransactionModel.in(tx).find(1)
        t0.in(tx).delete
        TransactionModel.in(tx).select.size.should eq(4)
        TransactionModel.in(tx).delete
        TransactionModel.in(tx).select.size.should eq(0)
      end
    end
  end
end


