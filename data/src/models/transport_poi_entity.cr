require "crystal_gpx"

struct TransportPoiEntity
  HOME_LAT = 52.40285
  HOME_LON = 16.91062
  HOME_POINT = CrystalGpx::Point.new(lat: HOME_LAT, lon: HOME_LON)

  @commune_slug : String
  @name : String
  @time_cost : Int32 # minutes
  @line_distance : Int32 # distance to Poznan in straight line

  @lat : Float64
  @lon : Float64

  getter :commune_slug, :name, :time_cost, :lat, :lon

  def initialize(y : YAML::Any)
    @commune_slug = y["commune_slug"].to_s
    @name = y["name"].to_s
    @time_cost = y["time_cost"].to_s.to_i
    @line_distance = y["line_distance"].to_s.to_i

    @lat = y["lat"].to_s.to_f
    @lon = y["lon"].to_s.to_f
  end

  def url
    "/town/#{@commune_slug}"
  end

  def distance_to(other : TransportPoiEntity)
    return CrystalGpx::Point.distance(
      lat1: self.lat,
      lon1: self.lon,
      lat2: other.lat,
      lon2: other.lon
    )
  end

  def distance_from_home
    return CrystalGpx::Point.distance(
      lat1: self.lat,
      lon1: self.lon,
      lat2: HOME_LAT,
      lon2: HOME_LON
    )
  end
end
