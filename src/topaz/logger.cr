require "logger"
require "singleton"

module Topaz
  class Log < SingleTon
    st_fields(
      {st_type: :property, name: debug_mode, type: Bool, df: false},
      {st_type: :property, name: show_query, type: Bool, df: false},
      {st_type: :property, name: log, type: Logger, df: Logger.new(STDOUT)}
    )

    def self.debug_mode(set : Bool)
      log = Topaz::Log.get_instance
      log.debug_mode = set
    end

    def self.show_query(set : Bool)
      log = Topaz::Log.get_instance
      log.show_query = set
    end

    def self.d(msg : String)
      log = Topaz::Log.get_instance
      log.d(msg)
    end

    def d(msg : String)
      @log.level = Logger::Severity::DEBUG if @debug_mode && @log.level != Logger::Severity::DEBUG
      @log.debug("\e[36m[Topaz] #{msg}\e[m") if @debug_mode
    end

    def self.i(msg : String)
      log = Topaz::Log.get_instance
      log.i(msg)
    end

    def i(msg : String)
      @log.info("\e[36m[Topaz] #{msg}\e[m")
    end

    def self.e(msg : String)
      log = Topaz::Log.get_instance
      log.e(msg)
    end

    def e(msg : String)
      @log.error("\e[31m[Topaz -- Error ] #{msg}\e[m")
    end

    def self.f(msg : String)
      log = Topaz::Log.get_instance
      log.f(msg)
    end

    def f(msg : String)
      @log.fatal("\e[31m[Topaz -- Error(Fatal) ] #{msg}\e[m")
    end

    def self.w(msg : String)
      log = Topaz::Log.get_instance
      log.w(msg)
    end

    def w(msg : String)
      @log.warn("\e[33m[Topaz -- Warning] #{msg}\e[m") if @debug_mode
    end

    def self.q(msg : String, tx = nil)
      log = Topaz::Log.get_instance
      log.q(msg, tx)
    end

    def q(msg : String, tx = nil)
      @log.level = Logger::Severity::DEBUG if @show_query && @log.level != Logger::Severity::DEBUG
      @log.debug("\e[33m[Topaz query] #{msg}\e[m") if @show_query && tx.nil?
      @log.debug("\e[33m[Topaz query] #{msg} | In transaction\e[m") if @show_query && !tx.nil?
    end
  end
end
