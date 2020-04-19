require "yaml"

class Tremolite::DataManager
  Log = ::Log.for(self)

  def initialize(@blog : Tremolite::Blog, @config_name = "config.yml")
    @data_path = @blog.data_path.as(String)

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
    path = File.join([@data_path, @config_name])

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
