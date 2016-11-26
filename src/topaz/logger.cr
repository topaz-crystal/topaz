
module Topaz
  class Logger

    @@debug = true
    @@show_query = false

    def self.debug(set : Bool)
      @@debug = set
    end

    def self.show_query(set : Bool)
      @@show_query = set
    end
    
    def self.v(msg : String)
      print "\e[36m[Topaz] #{msg}\e[m\n" if @@debug
    end

    def self.i(msg : String)
      print "\e[36m[Topaz info] #{msg}\e[m\n"
    end
    
    def self.e(msg : String)
      print "\e[31m[Topaz -- Error ] #{msg}\e[m\n"
    end

    def self.q(msg : String)
      print "\e[33m[Topaz query] #{msg}\e[m\n" if @@show_query
    end
  end
end
