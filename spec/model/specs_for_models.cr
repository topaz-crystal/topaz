require "../spec_helper"
require "./models"

macro select_db(db)
  Topaz::Db.setup("{{db.id}}")

  describe Topaz do

    it "Empty column" do
      EmptyColumn.drop_table
      EmptyColumn.create_table
      e = EmptyColumn.create
      e.id.should eq(1)
      EmptyColumn.select.size.should eq(1)
      EmptyColumn.select.first.id.should eq(1)
    end

    it "created_at and udpated_at" do
      EmptyColumn.drop_table
      EmptyColumn.create_table
      e0 = EmptyColumn.create
      e0.id.should eq(1)
      e1 = EmptyColumn.find(1)
      e0.created_at.as(Time).to_s(Topaz::Db.time_format).should eq(e1.created_at.as(Time).to_s(Topaz::Db.time_format))
      e0.updated_at.as(Time).to_s(Topaz::Db.time_format).should eq(e1.updated_at.as(Time).to_s(Topaz::Db.time_format))
      sleep 1
      e0.update
      e2 = EmptyColumn.create
      e2.id.should eq(2)
      e3 = EmptyColumn.find(2)
      s0 = e0.updated_at.as(Time) - e0.created_at.as(Time)
      s1 = e3.created_at.as(Time) - e0.created_at.as(Time)
      (s0.seconds >= 1).should eq(true)
      (s1.seconds >= 1).should eq(true)
    end

    it "Check all types" do
      AllTypes.drop_table
      AllTypes.create_table
      AllTypes.create("test", 10, 12.0f32, 10.0, Time.now)
      AllTypes.select.size.should eq(1)
    end

    it "Check Time" do
      AllTypes.drop_table
      AllTypes.create_table
      times = [Time.now - 10, Time.now]
      AllTypes.create("test", 10, 12.0f32, 10.0, times[0])
      AllTypes.create("test", 10, 12.0f32, 10.0, times[1])
      AllTypes.select.zip(times).each { |m, time| m.type_time == time }
    end

    it "Creates Int64 id" do
      IdInt64.drop_table
      IdInt64.create_table
      IdInt64.create
      IdInt64.select.size.should eq(1)
      IdInt64.select.first.id.class.to_s.should eq "Int64"
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
        up = UpdatedModel.create("mock#{i}", i)
        up.id.should eq(i+1)
        up.name.should eq("mock#{i}")
      end
      m = UpdatedModel.find(1)
      m.name = "mock_updated"
      m.update
      UpdatedModel.find(1).name.should eq("mock_updated")
      UpdatedModel.find(2).name.should eq("mock1")
      m2 = UpdatedModel.find(2)
      m2.update(name: "mock_updated2")
      m2.name.should eq("mock_updated2")
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

    it "Nullable column" do
      NullableModel.drop_table
      NullableModel.create_table

      NullableModel.new("ok0", 12, 12.0).save
      NullableModel.create("ok1", 12, 12.0)
      NullableModel.create("ok2", 12, nil)

      n0 = NullableModel.find(1)
      n0.test0.should eq("ok0")
      n0.test1.should eq(12)
      n0.test2.should eq(12.0)

      n1 = NullableModel.find(2)
      n1.test0.should eq("ok1")
      n1.test1.should eq(12)
      n1.test2.should eq(12.0)

      n0.update(test2: nil)
      n2 = NullableModel.find(1)
      n2.test2.should eq(nil)

      n3 = NullableModel.find(2)
      n3.test2 = nil
      n3.update

      n4 = NullableModel.find(2)
      n4.test2.should eq(nil)

      NullableModel.create("ok2", 13, nil)
      n5 = NullableModel.find(3)
      n5.test2.should eq(nil)
    end

    it "json" do

      JsonParent.drop_table
      JsonChild.drop_table

      JsonParent.create_table
      JsonChild.create_table

      p = JsonParent.create("John")
      c1 = JsonChild.create(12, p.id)
      c2 = JsonChild.create(15, p.id)
      c3 = JsonChild.create(23, p.id)

      time_p = p.created_at.as(Time).to_s("%FT%T%z")
      time_c1 = c1.created_at.as(Time).to_s("%FT%T%z")
      time_c2 = c2.created_at.as(Time).to_s("%FT%T%z")
      time_c3 = c3.created_at.as(Time).to_s("%FT%T%z")

      p.to_json.should eq("{\"id\":1,\"name\":\"John\",\"created_at\":\"#{time_p}\",\"updated_at\":\"#{time_p}\"}")
      c1.to_json.should eq("{\"id\":1,\"age\":12,\"p_id\":1,\"created_at\":\"#{time_c1}\",\"updated_at\":\"#{time_c1}\"}")
      c2.to_json.should eq("{\"id\":2,\"age\":15,\"p_id\":1,\"created_at\":\"#{time_c2}\",\"updated_at\":\"#{time_c2}\"}")
      c3.to_json.should eq("{\"id\":3,\"age\":23,\"p_id\":1,\"created_at\":\"#{time_c3}\",\"updated_at\":\"#{time_c3}\"}")

      p = JsonParent.from_json("{\"id\": -1, \"name\": \"Who\"}")
      p.save
      p.id.should eq(2)
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
