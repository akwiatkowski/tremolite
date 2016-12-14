require "yaml"

class Tremolite::VariableSet
  @@file_name = "config.yml"

  def initialize(@data_path : String)
    path = File.join([@data_path, @@file_name])
    @config = Hash(String, String).new

    YAML.parse(File.read(path)).as_h.each do |key, value|
      @config[key.to_s] = value.to_s
    end
  end

  def [](key : String) : String
    return @config[key]
  end

  def []?(key : String) : (String | Nil)
    return @config[key]?
  end
end
