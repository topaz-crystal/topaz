require "../spec_helper"
require "../../src/topaz/model"

class MockParent < Topaz::Model
  columns(
    {name: name, type: String},
    {has: MockChild, as: childs}
  )
end

class MockChild < Topaz::Model
  columns(
    {name: name, type: String},
    {name: parent_id, type: Int32, belongs: MockParent, as: parent}
  )
end

Spec.before_each do
  Topaz.setup("mysql://root@localhost/topaz")
  MockParent.create_table
  MockChild.create_table
end

Spec.after_each do
  MockParent.drop_table
  MockChild.drop_table
end

describe Topaz do
  it "associations" do
    
    p = MockParent.create("parent")
    
    c1 = MockChild.create("child1", p.id)
    c2 = MockChild.create("child2", p.id)
    c3 = MockChild.create("child3", p.id)

    p.childs.size.should eq(3)
    c1.parent.name.should eq("parent")
  end
end
