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
    {name: name, type: String}
  )

  has_many(
    {model: MockChild, as: childs, key: parent_id}
  )
end

class MockChild < Topaz::Model
  columns(
    {name: parent_id, type: Int32}
  )
  belongs_to(
    {model: MockParent, as: parent, key: parent_id}
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
    {name: name, type: String}
  )

  has_many(
    {model: MockChildSqlite3, as: childs, key: parent_id}
  )
end

class MockChildSqlite3 < Topaz::Model
  columns(
    {name: parent_id, type: Int64}
  )

  belongs_to(
    {model: MockParentSqlite3, as: parent, key: parent_id}
  )
end
