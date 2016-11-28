require "./topaz/*"

module Topaz
  
  @@setup = false
  @@env : String = ""

  # Setup db for Topaz.
  def self.setup(@@env : String)
    @@setup = true
  end

  # Get db information.
  # Exit with an error message if setup is not completed.
  def self.env
    error("Topaz is not initialized") unless @@setup
    @@env
  end

  def self.db
    
    error("Topaz is not initialized") unless @@setup
    
    if @@env.starts_with?("mysql://")
      :mysql
    elsif @@env.starts_with?("sqlite3://")
      :sqlite3
    else
      error("Unkown database: #{@@env}")
    end
  end
  
  private def self.error(msg : String)
    puts "Error: #{msg}"
    exit 1
  end
end
