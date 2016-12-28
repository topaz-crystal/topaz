require "../src/topaz"

# Migration is useful in the following case
# 1. You already define and create a model and columns
# 2. You've added or removed columns from defined model
# 3. You want to keep data of remaining columns

Topaz::Db.setup("mysql://root@localhost/topaz")
#Topaz::Db.setup("sqlite3://./db/sample.db")
#Topaz::Db.setup("postgres://root@localhost/topaz")
Topaz::Db.show_query(true)

macro before_migration
  class MigTest < Topaz::Model
    columns(
      column0: String,
      column1: {type: Int32, nullable: true},
    )
  end

  MigTest.drop_table
  MigTest.create_table
  
  MigTest.create("Name0", 0)
  MigTest.create("Name1", 1)
  MigTest.create("Name2", 2)
   
  MigTest.find(2).delete
  
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
  #MigTest.create(1, "column0", 2.3f32, 5)
end

#before_migration
after_migration

