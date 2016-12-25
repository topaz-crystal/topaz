# Define models for every tests

class EmptyColumn < Topaz::Model
  columns
end

class AllTypes < Topaz::Model
  columns(
    type_string: String,
    type_integer: Int32,
    type_float: Float32,
    type_double: Float64,
  )
end

class SearchedModel < Topaz::Model
  columns(
    name: String,
    age: Int32,
  )
end

class UpdatedModel < Topaz::Model
  columns(
    name: String,
    age: Int32,
  )
end

class DeletedModel < Topaz::Model
  columns(
    name: String,
    age: Int32,
  )
end

class NullableModel < Topaz::Model
  columns(
    test0: String,
    test1: {type: Int32, nullable: false},
    test2: {type: Float64, nullable: true},
  )
end

class JsonParent < Topaz::Model
  columns(name: String)
  has_many(
    childlen: {model: JsonChild, key: p_id},
    pets: {model: JsonPet, key: p_id}
  )
end

class JsonChild < Topaz::Model
  columns(
    age: Int32,
    p_id: Int32
  )
  has_many(toies: {model: JsonToy, key: c_id})
  belongs_to(parent: {model: JsonParent, key: p_id})
end

class JsonPet < Topaz::Model
  columns(p_id: Int32)
  belongs_to(parent: {model: JsonParent, key: p_id})
end

class JsonToy < Topaz::Model
  columns(
    name: String,
    price: Int32,
    c_id: Int32
  )
  has_many(parts: {model: JsonPart, key: t_id})
  belongs_to(child: {model: JsonChild, key: c_id})
end

class JsonPart < Topaz::Model
  columns(t_id: Int32)
  belongs_to(toy: {model: JsonToy, key: t_id})
end

class TransactionModel < Topaz::Model
  columns(name: String)
end
