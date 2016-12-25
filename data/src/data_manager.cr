require "./models/town_entity"
require "./models/tag_entity"
require "./models/land_type_entity"
require "./models/land_entity"
require "./models/train_cost_entity"
require "./models/todo_route_entity"

class Tremolite::DataManager
  def custom_initialize
    @towns = Array(TownEntity).new
    @voivodeships = Array(TownEntity).new
    @tags = Array(TagEntity).new
    @land_types = Array(LandTypeEntity).new
    @lands = Array(LandEntity).new
    @train_costs = Array(TrainCostEntity).new
    @todo_routes = Array(TodoRouteEntity).new
  end

  getter :tags, :towns, :voivodeships, :land_types, :lands, :todo_routes

  def custom_load
    load_towns
    load_tags
    load_land_types
    load_lands
    load_train_costs
    load_todo_routes
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

  def load_land_types
    f = File.join([@data_path, "land_types.yml"])
    YAML.parse(File.read(f)).each do |tag|
      o = LandTypeEntity.new(tag)
      @land_types.not_nil! << o
    end
  end

  def load_lands
    f = File.join([@data_path, "lands.yml"])
    YAML.parse(File.read(f)).each do |tag|
      o = LandEntity.new(tag)
      @lands.not_nil! << o
    end
  end

  def load_train_costs
    f = File.join([@data_path, "train_costs.yml"])
    YAML.parse(File.read(f)).each do |tag|
      o = TrainCostEntity.new(tag)
      @train_costs.not_nil! << o
    end
  end

  def load_todo_routes
    f = File.join([@data_path, "todo_routes.yml"])
    YAML.parse(File.read(f)).each do |tag|
      o = TodoRouteEntity.new(y: tag, train_costs: @train_costs.not_nil!, logger: @logger)
      @todo_routes.not_nil! << o
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
