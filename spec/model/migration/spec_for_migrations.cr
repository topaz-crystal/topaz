require "../../spec_helper"

macro before_migration(db)

  Topaz::Db.setup("{{db.id}}")

  class MigTest < Topaz::Model
    columns(
      col0: String,
      col1: {type: Int32, nullable: true},
      col2: {type: Float64, nullable: true},
    )
  end

  describe "Before Migration" do
    it "create original table" do
      MigTest.drop_table
      MigTest.create_table

      m0 = MigTest.create("name0", 10, 2.3)
      m1 = MigTest.create("name1", 11, 2.4)
      m2 = MigTest.create("name2", 12, 2.5)

      m0.id.should eq(1)
      m1.id.should eq(2)
      m2.id.should eq(3)

      m0.col0.should eq("name0")

      _m0 = MigTest.find(1)
      _m0.col0.should eq("name0")
    end
  end
end

macro exec_migration(db)

  Topaz::Db.setup("{{db.id}}")

  class MigTest < Topaz::Model
    columns(
      col0: String,
      col0_1: String, # added column
      col0_2: Int32, # added column
      col1: {type: Int32, nullable: true},
      col1_5: {type: String, nullable: true}, # added column
      # col2: {type: Float64, nullable: true}, # removed column
    )
  end

  describe "Execute migration" do
    it "migrate table" do
      MigTest.migrate_table
      m0 = MigTest.create("mname0", "added column1", 33, 13, "1_5")
      m1 = MigTest.create("mname1", "added column2", 34, 14, "1_6")

      m0.id.should eq(4)
      m1.id.should eq(5)

      m0.col1_5.should eq("1_5")
      m1.col0_2.should eq(34)

      m2 = MigTest.find(4)
      m2.col0.should eq("mname0")
    end
  end
end
