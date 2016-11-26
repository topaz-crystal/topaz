
module Topaz
  # A logger for Topaz.
  # Set log level by self.debug and self.show_query.
  class Logger

    @@debug = true
    @@show_query = false

    # Set log level for debug.
    # If you set it 'true', print out all most all logs.
    def self.debug(set : Bool)
      @@debug = set
    end

    # Set log level for queries.
    # If you set it 'true', print out all queries that Topaz throws.
    def self.show_query(set : Bool)
      @@show_query = set
    end
    
    protected def self.v(msg : String)
      print "\e[36m[Topaz] #{msg}\e[m\n" if @@debug
    end

    protected def self.i(msg : String)
      print "\e[36m[Topaz info] #{msg}\e[m\n"
    end
    
    protected def self.e(msg : String)
      print "\e[31m[Topaz -- Error ] #{msg}\e[m\n"
    end

    protected def self.q(msg : String)
      print "\e[33m[Topaz query] #{msg}\e[m\n" if @@show_query || @@debug
    end
  end
end
