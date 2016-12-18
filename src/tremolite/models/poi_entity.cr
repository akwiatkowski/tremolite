struct PoiEntity
  @name : String
  @lat : Float64
  @lon : Float64

  getter :name, :lat, :lon

  def initialize(y : YAML::Any)
    @name = y["name"].to_s
    @lat = y["lat"].to_s.to_f
    @lon = y["lon"].to_s.to_f
  end

  def ump_map_url
    "http://mapa.ump.waw.pl/ump-www/?zoom=13&lat=#{@lat}&lon=#{@lon}&mlat=#{@lat}&mlon=#{@lon}"
  end

  def link_tag
    "<a target=\"_blank\" href=\"#{ump_map_url}\">#{@name}</a>"
  end

  def wrapped_link
    "<li>#{link_tag}</li>\n"
  end
end
