require "./spec_helper"
require "sqlite3"

describe Topaz do
  it "Setup db without any errors" do
    Topaz::Db.setup("sqlite3://./db/sample.db")
    Topaz::Db.close
  end

  it "Close db before opening" do
    expect_raises Exception do
      Topaz::Db.close
    end
  end
end
