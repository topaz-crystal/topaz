require "../src/topaz"
require "sqlite3"

######################
# Transaction Sample #
######################

# Transaction is supported for Topaz::Model
# Here we define a simple model
class TransactionSample < Topaz::Model
  columns(name: String)
end

Topaz::Db.setup("sqlite3://./db/sample.db")

TransactionSample.drop_table
TransactionSample.create_table

# In transaction, we use `in` method to pass the connection to models
# To open a transaction we do like this
# Topaz::Db.shared is a DB::Database instance that you set
Topaz::Db.shared.transaction do |tx|
  # Here is in transaction
  # All operation can be rollbacked if some errors happen
  TransactionSample.in(tx).create("sample0")
  TransactionSample.in(tx).create("sample1")
  # You can find models by
  TransactionSample.in(tx).find(1).name
  # => sample0
  TransactionSample.in(tx).where("name = \'sample1\'").select.size
  # => 1
  # You can update them
  t0 = TransactionSample.in(tx).find(1)
  t0.in(tx).update(name: "sample0 updated")
  TransactionSample.in(tx).find(1).name
  # => sample0 updated
  # You can delete them
  t1 = TransactionSample.in(tx).find(2)
  t1.in(tx).delete
  TransactionSample.in(tx).select.size
  # => 1

  # You cannot call mutiple database operation at the same time like
  # TransactionSample.in(tx).find(1).update(name: "error!")
  # Because found model by `find(1)` is not in the transaction.
  # So it should be like
  # TransactionSample.in(tx).find(1).in(tx).update(name: "Safe call!")
end
