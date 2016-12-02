require "../spec_helper"

class AllTypes < Topaz::Model
  columns(
    {name: type_string, type: String},
    {name: type_integer, type: Int32},
    {name: type_float, type: Float32},
    {name: type_double, type: Float64},
  )
end

class MockModel < Topaz::Model
  columns(
    {name: name, type: String},
    {name: age, type: Int32},
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

class AllTypesSqlite3 < Topaz::Model
  columns(
    {name: type_string, type: String},
    {name: type_integer, type: Int64},
    {name: type_double, type: Float64},
  )
end

class MockModelSqlite3 < Topaz::Model
  columns(
    {name: name, type: String},
    {name: age, type: Int64},
  )
end

class MockParentSqlite3 < Topaz::Model
  columns(
    {has: MockChildSqlite3, as: childs}
  )
end

class MockChildSqlite3 < Topaz::Model
  columns(
    {name: parent_id, type: Int64, belongs: MockParentSqlite3, as: parent}
  )
end
