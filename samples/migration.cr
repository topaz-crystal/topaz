require "../src/topaz"

Topaz::Db.setup("sqlite3://./db/sample.db")

###################
# Table Migration #
###################
#
# Migration is useful in the following case
# 1. You'd already defined and created a model and columns
# 2. You've added or removed columns from the defined model
# 3. You want to keep data of remaining columns
#
# We assume the case that we've already defined
#
# [Defined Model]
# class MigrationSample < Topaz::Model
#   columns(
#     name: String,
#     age: Int32,
#   )
# end
#
# And you'd created a table
# MigrationSample.drop_table
# MigrationSample.create_table
#
# MigrationSample.create("SampleName", 25)
#
# After that, you've removed 'age' column and added score column like
#
# [Redefined model]
# class MigrationSample < Topaz::Model
#   columns(
#     name: String,
#     score: Int32,
#   )
# end
#
# In this case, you can call Topaz::Model#migrate_table to keep the remaining data like
# MigrationSample.migrate_table
# MigrationSample.find(1).name
# => "SampleName"
