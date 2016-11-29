require "../spec_helper"
require "./models"
 
describe Topaz do
  it "associations" do
    
    p = MockParent.create
    
    c1 = MockChild.create(p.id)
    c2 = MockChild.create(p.id)
    c3 = MockChild.create(p.id)
 
    p.childs.size.should eq(3)
    c1.parent.id.should eq(1)
  end
end
