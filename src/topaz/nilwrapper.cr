# In SQLite3, all data is saved as 64 bits.
# So we need to convert it to 32 bits variables if the code define it so.
# See model.cr to know how to use this.
class Nilwrapper
  
  def self.to_i32
    nil
  end

  def self.to_f32
    nil
  end
end
