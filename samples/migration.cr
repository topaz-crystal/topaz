require "../src/topaz"

Topaz::Db.setup("sqlite3://./db/sample.db")

####################
# Migration Sample #
####################
# You can create tables on your database by calling Model#create_table.
# Then id(Int32), created_at(Time) and updated_at(Time) are created automatically.
# If you want to add or remove column after you create it, please execute a query manually.
#
# So I recommend you to create models folder and define models into it.
#
# [in src/migration/sample.cr]
class MigrationSample < Topaz::Model
  columns(
    sample: String,
    score: Int32,
  )
end
#
# migration file should be isolated from model.cr file
# You can define it like
#
# [in src/migration/sample.cr]
MigrationSample.create_table
#
# Then you can create a table by execute following command
# `crystal run src/migration/sample.cr`
# After you create the model, you can handle it like
s = MigrationSample.create("AAA", 15)
puts s.id         # => 1
puts s.sample     # => "AAA"
puts s.score      # => 15
puts s.created_at # => some time
puts s.updated_at # => some time
#
# You can drop the table by
MigrationSample.drop_table
# Call this carefully since this deletes all data 
