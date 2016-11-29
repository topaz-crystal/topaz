require "../spec_helper"

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

class MockParent < Topaz::Model
  columns(
    {has: MockChild, as: childs}
  )
end
 
class MockChild < Topaz::Model
  columns(
    {name: parent_id, type: Int32, belongs: MockParent, as: parent}
  )
end

Spec.before_each do
  Topaz.setup("mysql://root@localhost/topaz")
  MockModel.create_table
  MockParent.create_table
  MockChild.create_table
  AllTypes.create_table
end

Spec.after_each do
  MockModel.drop_table
  MockParent.drop_table
  MockChild.drop_table
  AllTypes.drop_table
  Topaz.clean
end
