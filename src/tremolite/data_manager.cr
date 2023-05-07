require "yaml"

class Tremolite::DataManager
  Log = ::Log.for(self)

  def initialize(@blog : Tremolite::Blog, @config_path)
    @data_path = @blog.data_path.as(String)
    @config_path = @data_path if @config_path.to_s == ""

    @config_hash = Hash(String, String).new

    Log.debug { "START" }

    custom_initialize
    load_data

    Log.debug { "INITIALIZED" }
  end

  def custom_initialize
    # customize
  end

  def load_data
    load_config
    custom_load
  end

  def custom_load
    # customize
  end

  def load_config
    path = File.join([@config_path, "config.yml"])

    YAML.parse(File.read(path)).as_h.each do |key, value|
      @config_hash[key.to_s] = value.to_s
    end
  end

  def [](key : String) : String
    return @config_hash[key]
  end

  def []?(key : String) : (String | Nil)
    return @config_hash[key]?
  end
end
