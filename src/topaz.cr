require "./topaz/*"

module Topaz
  
  @@setup = false
  @@env : String = ""

  # Setup db for Topaz.
  # Currently support only crystal-lgn/crystal-mysql, but will support crystal-sqlite as well.
  def self.setup(@@env : String)
    @@setup = true
  end

  # Get db information.
  # Exit with an error message if setup is not completed.
  def self.env
    error("Topaz is not initialized") unless @@setup
    @@env
  end
  
  private def self.error(msg : String)
    puts "Error: #{msg}"
    exit 1
  end
end
