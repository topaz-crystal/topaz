require "../spec_helper"
require "./models"

describe Topaz do
  describe "MySQL" do
    Spec.before_each do
      Topaz::Db.setup("mysql://root@localhost/topaz")
      MockModel.create_table
      MockParent.create_table
      MockChild.create_table
      AllTypes.create_table
    end

    Spec.after_each do
      MockModel.drop_table
      MockChild.drop_table
      MockParent.drop_table
      AllTypes.drop_table
      Topaz::Db.clean
    end
    it "[MySQL] All data types" do
      AllTypes.create("test", 10, 10.0f32, 20.0)
      AllTypes.select.size.should eq(1)
    end

    it "[MySQL] Create models" do
      m1 = MockModel.new("mock1", 12).save
      m2 = MockModel.create("mock2", 13)
      MockModel.select.size.should eq(2)
    end

    it "[MySQL] Find models" do
      10.times do |i|
        MockModel.create("mock#{i}", i)
      end
      MockModel.find(1).name.should eq("mock0")
      MockModel.where("name = 'mock0'").select.size.should eq(1)
      MockModel.order("age", "desc").range(1, 3).select.first.name.should eq("mock8")
    end

    it "[MySQL] Update models" do
      10.times do |i|
        MockModel.create("mock#{i}", i)
      end
      m = MockModel.find(1)
      m.name = "mock_updated"
      m.update
      MockModel.find(1).name.should eq("mock_updated")

      m2 = MockModel.find(2)
      m2.update({name: "mock_updated2"})
      MockModel.find(2).name.should eq("mock_updated2")
      MockModel.update({name: "mock_udpated_all"})
      MockModel.where("name = 'mock_udpated_all'").select.size.should eq(10)
    end

    it "[MySQL] Delete models" do
      10.times do |i|
        MockModel.create("mock#{i}", i)
      end

      MockModel.find(1).delete
      MockModel.select.size.should eq(9)
      MockModel.delete
      MockModel.select.size.should eq(0)
    end

    it "[MySQL] Associations" do
      p = MockParent.create
      c1 = MockChild.create(p.id)
      c2 = MockChild.create(p.id)
      c3 = MockChild.create(p.id)
      p.childs.size.should eq(3)
      c1.parent.id.should eq(1)
    end
  end
end
