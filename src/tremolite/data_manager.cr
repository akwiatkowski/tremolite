require "yaml"

class Tremolite::DataManager
  def initialize(@blog : Tremolite::Blog, @config_name = "config.yml")
    @logger = @blog.logger.as(Logger)
    @data_path = @blog.data_path.as(String)

    @config_hash = Hash(String, String).new

    custom_initialize
    load_data
  end

  def custom_initialize
    # customize
  end

  def load_data
    @logger.info("DataManager: START")

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
