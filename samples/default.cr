require "../src/topaz"
require "sqlite3"

#############################
# Column with default value #
#############################
# You can set default value for columns
class DefaultModel < Topaz::Model
  columns(
    without_default: String,
    with_default: {type: String, default: "default value"},
    with_default2: {type: String, default: "default value 2"},
    with_nil_default: {type: String, nullable: true}, # The default value is `nil`
  )
  # **Note**
  # Please define columns WITHOUT default values first.
  # So following code is NOT allowed
  # ```
  # columns(
  #   with_default: {type: String, default: "default value"},
  #   without_default: String, <- This column should be defined at first
  #   with_default2: {type: String, default: "default value 2"},
  #   with_nil_default: {type: String, nullable: true},
  # )
  # ```
  # See the discussion here: https://github.com/topaz-crystal/topaz/issues/8
end

Topaz::Db.setup("sqlite3://./db/sample.db")

# Setup table
DefaultModel.drop_table
DefaultModel.create_table

# You can create models with default values like this
DefaultModel.create("val0", "val1", "val2") # <- with_nil_default is "nil"
DefaultModel.create("val0", "val1")         # <- with_nil_default is "nil" and with_default2 is "default value 2"
DefaultModel.create("val0")                 # <- with_nil_default is "nil", with_default is "default value" and with_default2 is "default value 2"

DefaultModel.find(3).with_default2
# => "default value 2"
