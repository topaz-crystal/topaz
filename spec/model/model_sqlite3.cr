require "../spec_helper"
require "./models"

describe Topaz do
  describe "SQLite3" do
    Spec.before_each do
      Topaz::Db.setup("sqlite3://./db/data.db")
      MockModelSqlite3.create_table
      MockParentSqlite3.create_table
      MockChildSqlite3.create_table
      AllTypesSqlite3.create_table
    end

    Spec.after_each do
      MockModelSqlite3.drop_table
      MockChildSqlite3.drop_table
      MockParentSqlite3.drop_table
      AllTypesSqlite3.drop_table
      Topaz::Db.clean
    end
    it "[SQLite3] All data types" do
      AllTypesSqlite3.create("test", 10.to_i64, 10.0)
      AllTypesSqlite3.select.size.should eq(1)
    end
    it "[SQLite3] Create models" do
      m1 = MockModelSqlite3.new("mock1", 12.to_i64).save
      m2 = MockModelSqlite3.create("mock2", 13.to_i64)
      MockModelSqlite3.select.size.should eq(2)
    end
    it "[SQLite3] Find models" do
      10.times do |i|
        MockModelSqlite3.create("mock#{i}", i.to_i64)
      end
      MockModelSqlite3.find(1).name.should eq("mock0")
      MockModelSqlite3.where("name = 'mock0'").select.size.should eq(1)
      MockModelSqlite3.order("age", "desc").range(1, 3).select.first.name.should eq("mock8")
    end
    it "[SQLite3] Update models" do
      10.times do |i|
        MockModelSqlite3.create("mock#{i}", i.to_i64)
      end
      m = MockModelSqlite3.find(1)
      m.name = "mock_updated"
      m.update
      MockModelSqlite3.find(1).name.should eq("mock_updated")
      m2 = MockModelSqlite3.find(2)
      m2.update({name: "mock_updated2"})
      MockModelSqlite3.find(2).name.should eq("mock_updated2")
      MockModelSqlite3.update({name: "mock_udpated_all"})
      MockModelSqlite3.where("name = 'mock_udpated_all'").select.size.should eq(10)
    end
    it "[SQLite3] Delete models" do
      10.times do |i|
        MockModelSqlite3.create("mock#{i}", i.to_i64)
      end
      MockModelSqlite3.find(1).delete
      MockModelSqlite3.select.size.should eq(9)
      MockModelSqlite3.delete
      MockModelSqlite3.select.size.should eq(0)
    end
    it "[SQLite3] Associations" do
      p = MockParentSqlite3.create
      c1 = MockChildSqlite3.create(p.id.to_i64)
      c2 = MockChildSqlite3.create(p.id.to_i64)
      c3 = MockChildSqlite3.create(p.id.to_i64)
      p.childs.size.should eq(3)
      c1.parent.id.should eq(1)
    end
  end
end
