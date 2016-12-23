require "./models/town_entity"
require "./models/tag_entity"
require "./models/land_entity"

class Tremolite::DataManager
  def custom_initialize
    @towns = Array(TownEntity).new
    @voivodeships = Array(TownEntity).new
    @tags = Array(TagEntity).new
    @lands = Array(LandEntity).new
  end

  getter :tags, :towns, :voivodeships, :lands

  def custom_load
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
      @tags.not_nil! << o
    end
  end

  def load_lands
    f = File.join([@data_path, "lands.yml"])
    YAML.parse(File.read(f)).each do |tag|
      o = LandEntity.new(tag)
      @lands.not_nil! << o
    end
  end

  private def load_town_yaml(f)
    YAML.parse(File.read(f)).each do |town|
      o = TownEntity.new(town)
      @towns.not_nil! << o if o.is_town?
      @voivodeships.not_nil! << o if o.is_voivodeship?
    end

    @towns = @towns.not_nil!.sort { |a, b| a.slug <=> b.slug }.uniq { |a| a.slug }
    @voivodeships = @voivodeships.not_nil!.sort { |a, b| a.slug <=> b.slug }.uniq { |a| a.slug }
  end
end
