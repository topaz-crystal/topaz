require "singleton"
require "mysql"
require "sqlite3"

module Topaz
  class Db < SingleTon
    st_fields(
      {st_type: :property, name: info, type: String, df: ""},
    )

    def self.setup(info)
      db = self.get_instance
      Topaz::Log.e("Topaz is already setup with #{db.info}: #{info}") unless db.info.empty?
      db.info = info
    end

    def self.clean
      db = self.get_instance
      Topaz::Log.e("Topaz is not initialized") if db.info.empty?
      db.info = ""
    end

    def self.type
      db = Db.get_instance
      Topaz::Log.f("Topaz is not initialized") if db.info.empty?
      if db.info.starts_with?("mysql://")
        :mysql
      elsif db.info.starts_with?("sqlite3://")
        :sqlite3
      else
        Topaz::Log.e("Unkown database: #{db.info}")
      end
    end

    def self.open(&block)
      topaz_db = Db.get_instance
      real_db = DB.open topaz_db.info
      yield real_db
    end
  end
end
