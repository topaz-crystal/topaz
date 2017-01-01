require "../src/topaz"

# Migration is useful in the following case
# 1. You already define and create a model and columns
# 2. You've added or removed columns from the defined model
# 3. You want to keep data of remaining columns

# We assume the case that we've already defined

#Topaz::Db.setup("mysql://root@localhost/topaz")
#Topaz::Db.setup("sqlite3://./db/sample.db")
Topaz::Db.setup("postgres://root@localhost/topaz")
Topaz::Db.show_query(true)

macro before_migration
  class MigTest < Topaz::Model
    columns(
      column0: String,
      column1: {type: Int32, nullable: true},
      column4: {type: Float32, nullable: true},
    )
  end

  MigTest.drop_table
  MigTest.create_table
  
  MigTest.create("Name0", 0, 3.2f32)
  MigTest.create("Name1", 1, 2.4f32)
  MigTest.create("Name2", nil, nil)
  MigTest.find(2).delete
  puts MigTest.find(3).column1.nil?
  puts MigTest.find(3).column4.nil?
end

macro after_migration
  # Added column_super, column2 and column3
  # Removed column1
  class MigTest < Topaz::Model
    columns(
      column_super: Int32,
      column0: String,
      column2: Float32,
      column3: {type: Int32, nullable: true},
    )
  end

  MigTest.migrate_table
  MigTest.create(1, "column0", 2.3f32, 5)
  MigTest.create(2, "column0", 2.3f32, 5)
  m3 = MigTest.create(3, "column0", 2.3f32, 5)
  puts m3.id
end

#before_migration
after_migration

