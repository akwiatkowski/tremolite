require "yaml"

require "./models/town_entity"
require "./models/tag_entity"
require "./models/land_entity"

class Tremolite::DataManager
  def initialize(@blog : Tremolite::Blog, @config_name = "config.yml")
    @logger = @blog.logger.as(Logger)
    @data_path = @blog.data_path.as(String)

    @config_hash = Hash(String, String).new

    @towns = Array(TownEntity).new
    @voivodeships = Array(TownEntity).new
    @tags = Array(TagEntity).new
    @lands = Array(LandEntity).new

    load
  end

  getter :tags, :towns, :voivodeships, :lands

  def load
    @logger.info("DataManager: START")

    load_config
    load_towns
    load_tags
    load_lands
  end

  def load_towns
    Dir[File.join([@data_path, "towns", "**", "*"])].each do |f|
      if File.file?(f)
        load_town_yaml(f)
      end
    end
  end

  def load_tags
    f = File.join([@data_path, "tags.yml"])
    YAML.parse(File.read(f)).each do |tag|
      o = TagEntity.new(tag)
      @tags << o
    end
  end

  def load_lands
    f = File.join([@data_path, "lands.yml"])
    YAML.parse(File.read(f)).each do |tag|
      o = LandEntity.new(tag)
      @lands << o
    end
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

  private def load_town_yaml(f)
    YAML.parse(File.read(f)).each do |town|
      o = TownEntity.new(town)
      @towns << o if o.is_town?
      @voivodeships << o if o.is_voivodeship?
    end

    @towns = @towns.sort { |a, b| a.slug <=> b.slug }.uniq { |a| a.slug }
    @voivodeships = @voivodeships.sort { |a, b| a.slug <=> b.slug }.uniq { |a| a.slug }
  end
end
