struct TrainCostEntity
  @commune_slug : String
  @name : String
  @time_cost : Int32 # minutes
  @line_distance : Int32 # distance to Poznan in straight line

  getter :commune_slug, :name, :time_cost

  def initialize(y : YAML::Any)
    @commune_slug = y["commune_slug"].to_s
    @name = y["name"].to_s
    @time_cost = y["time_cost"].to_s.to_i
    @line_distance = y["line_distance"].to_s.to_i
  end

  def url
    "/town/#{@commune_slug}"
  end
end
