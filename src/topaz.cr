require "./topaz/*"

module Topaz
  
  @@setup = false
  @@env : String = ""
  
  def self.setup(@@env : String)
    @@setup = true
  end
  
  def self.env
    error("Topaz is not initialized") unless @@setup
    @@env
  end
  
  private def self.error(msg : String)
    puts "Error: #{msg}"
    exit 1
  end
end
