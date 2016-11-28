require "../spec_helper"
require "../../src/topaz/model"

class MockModel < Topaz::Model
  columns(
    {name: name, type: String},
    {name: age, type: Int32},
  )
end

class AllTypes < Topaz::Model
  columns(
    {name: type_string, type: String},
    {name: type_integer, type: Int32},
    {name: type_float, type: Float32},
    {name: type_double, type: Float64},
  )
end

Spec.before_each do
  Topaz.setup("mysql://root@localhost/topaz")
  MockModel.create_table
end

Spec.after_each do
  MockModel.drop_table
end

describe Topaz do

  it "create models" do
    m1 = MockModel.new("mock1", 12).save
    m2 = MockModel.create("mock2", 13)
    MockModel.select.size.should eq(2)
  end

  it "all data types" do
    AllTypes.create_table
    AllTypes.create("test", 10, 10.0f32, 20.0)
    AllTypes.drop_table
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
end
