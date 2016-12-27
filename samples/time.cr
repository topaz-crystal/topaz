require "../src/topaz"

#############################
# created_at and updated_at #
#############################

# Topaz is defined created_at(Time) and updated_at(Time) by default
# You can access them after create or update model.
# (updated_at is also saved when you create it.)
# Time format is defined at Topaz::Model::TIME_FORMAT.

class TimeModel < Topaz::Model
  columns # empty column
end

Topaz::Db.setup("sqlite3://./db/sample.db")

TimeModel.drop_table
TimeModel.create_table

# create a model
TimeModel.create

t = TimeModel.find(1)
t.created_at
# => 2016-12-26 00:32:59 +0900 (just an example)
typeof(t.created_at)
# => Time|Nil
t.updated_at
# => 2016-12-26 00:32:59 +0900 (just an example)
typeof(t.updated_at)
# => Time|Nil

sleep 1 # wait 1 sec
t.update

span = t.updated_at.as(Time) - t.created_at.as(Time)
span.seconds >= 1
# => true
