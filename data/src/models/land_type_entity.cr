struct LandTypeEntity
  @slug : String
  @name : String

  getter :name, :slug

  def initialize(y : YAML::Any)
    @slug = y["slug"].to_s
    @name = y["name"].to_s
  end
end
