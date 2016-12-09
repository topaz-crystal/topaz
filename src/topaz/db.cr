require "singleton"
require "mysql"
require "sqlite3"

module Topaz
  class Db

    @@shared : DB::Database|Nil

    def self.setup(connection : String)
      setup(URI.parse(connection))
    end

    def self.setup(uri : URI)
      @@shared = DB.open(uri)
    end

    def self.shared
      check
      @@shared.as(DB::Database)
    end

    def self.close
      check
      @@shared.as(DB::Database).close
    end

    def self.scheme
      check
      @@shared.as(DB::Database).uri.scheme
    end

    def self.check
      raise "Database is not initialized, please call Topaz::Db.setup(String|URI)" if @@shared.nil?
    end
  end
end
