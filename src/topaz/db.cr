require "singleton"
require "mysql"
require "sqlite3"
require "pg"

module Topaz
  class Db
    @@shared : DB::Database | Nil

    # Setup a database by connection uri as String
    # See official sample for detail
    # For MySQL https://github.com/crystal-lang/crystal-mysql
    # For SQLite3 https://github.com/crystal-lang/crystal-sqlite3
    def self.setup(connection : String)
      setup(URI.parse(connection))
    end

    # Setup a database by connection uri
    def self.setup(uri : URI)
      @@shared = DB.open(uri)
    end

    def self.shared
      check
      @@shared.as(DB::Database)
    end

    # Close the database
    def self.close
      check
      @@shared.as(DB::Database).close
      @@shared = nil
    end

    protected def self.scheme
      check
      @@shared.as(DB::Database).uri.scheme
    end

    protected def self.check
      raise "Database is not initialized, please call Topaz::Db.setup(String|URI)" if @@shared.nil?
    end
  end
end
