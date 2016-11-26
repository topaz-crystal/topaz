# This spec needs Topaz::Model
require "../../src/topaz/model"

# This is a test code for Topaz::Model
# This spec requires actual table named 'topaz' in localhost MySQL.

class MockModel < Topaz::Model
  attrs(
    {name: name, type: String},
    {name: age, type: Int32},
  )
end

class MockParent < Topaz::Model
  attrs({name: name, type: String})
  has({model: MockChild, as: childs, id: parent_id})
end

class MockChild < Topaz::Model
  attrs({name: name, type: String},
        {name: parent_id, type: Int32})
  belongs({model: MockParent, as: parent, id: parent_id})
end

Spec.before_each do
  Topaz.setup("mysql://root@localhost/topaz")
  Topaz::Logger.debug(false)
  Topaz::Logger.show_query(false)
  MockModel.create_table
  MockParent.create_table
  MockChild.create_table
end

Spec.after_each do
  MockModel.drop_table
  MockParent.drop_table
  MockChild.drop_table
end

describe Topaz do

  it "create models" do
    m1 = MockModel.new("mock1", 12).save
    m2 = MockModel.create("mock2", 13)
    MockModel.select.size.should eq(2)
  end

  it "find models" do
    10.times do |i|
      MockModel.create("mock#{i}", i)
    end
    MockModel.find(1).name.should eq("mock0")
    MockModel.where("name = 'mock0'").select.size.should eq(1)
    MockModel.order("age", "desc").range(1, 3).select.first.name.should eq("mock8")
  end

  it "update models" do
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

  it "delete models" do
    10.times do |i|
      MockModel.create("mock#{i}", i)
    end

    MockModel.find(1).delete
    MockModel.select.size.should eq(9)
    MockModel.delete
    MockModel.select.size.should eq(0)
  end

  it "relations" do
    
    p = MockParent.create("parent")
    
    c1 = MockChild.create("child1", p.id)
    c2 = MockChild.create("child2", p.id)
    c3 = MockChild.create("child3", p.id)

    p.childs.size.should eq(3)
    c1.parent.name.should eq("parent")
  end
end
