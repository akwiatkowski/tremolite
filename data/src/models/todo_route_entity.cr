require "yaml"
require "logger"

require "./transport_poi_entity"

struct TodoRouteEntity
  @voivodeship : String
  @type : String # bicycle, hike
  @distance : Float64 # kilometers
  @time_length : Float64 # hours
  @from : String
  @to : String
  @url : String
  @desc_url : (String | Nil)

  @from_poi : (TransportPoiEntity | Nil)
  @to_poi : (TransportPoiEntity | Nil)

  # loaded from other TrainCostEntity
  @train_start_cost : Int32 # minutes of train ride from home to start
  @train_end_cost : Int32 # minutes of train ride from end to home

  # some routes are `true external`, that means they are not sensible
  # without having set "external HQ" (accommodation)
  #
  # in this case stats related to train travel from HQ are not usable
  @train_return_time_cost : (Int32 | Nil)

  getter :voivodeship, :type, :distance, :time_length, :url, :desc_url, :from, :to
  getter :train_start_cost, :train_end_cost

  def initialize(y : YAML::Any, transport_pois : Array(TransportPoiEntity), @logger : Logger)
    @voivodeship = y["voivodeship"].to_s
    @type = y["type"].to_s
    @distance = y["distance"].to_s.to_f
    @time_length = y["time_length"].to_s.to_f
    @url = y["url"].to_s

    @from = y["from"].to_s
    @to = y["to"].to_s

    t = transport_pois.select{|tc| tc.name == @from }
    if t.size > 0
      @from_poi = t.first.as(TransportPoiEntity)
      @train_start_cost = @from_poi.not_nil!.time_cost
    else
      @logger.error("TodoRouteEntity: NOT FOUND FOR #{@from}".colorize(:red))
      @train_start_cost = -1
      raise "TodoRouteEntity: NOT FOUND FOR #{@from}"
    end

    t = transport_pois.select{|tc| tc.name == @to }
    if t.size > 0
      @to_poi = t.first.as(TransportPoiEntity)
      @train_end_cost = @to_poi.not_nil!.time_cost
    else
      @logger.error("TodoRouteEntity: NOT FOUND FOR #{@to}".colorize(:red))
      @train_end_cost = -1
      raise "TodoRouteEntity: NOT FOUND FOR #{@to}"
    end

    @desc_url = y["desc_url"].to_s if y["desc_url"]?
    @train_return_time_cost = y["train_return_time_cost"].to_s.to_i if y["train_return_time_cost"]?
  end

  def time_length_hours
    time_length
  end

  def train_total_cost
    @train_start_cost + @train_end_cost
  end

  def train_total_cost_minutes
    train_total_cost.to_f
  end

  def transport_total_cost_hours
    train_total_cost.to_f / 60.0
  end

  def total_cost_hours
    transport_total_cost_hours.to_f + time_length.to_f
  end

  def time_length_percentage
    100.0 * time_length_hours / total_cost_hours
  end

  def straight_line_length
    return @from_poi.not_nil!.distance_to(@to_poi.not_nil!)
  end

  def distance_to_straight
    return (distance / straight_line_length)
  end

  def distance_to_straigh_percentage
    (distance_to_straight - 1.0) * 100.0
  end

  def center_point : CrystalGpx::Point
    p = CrystalGpx::Point.new(
      lat: (@from_poi.not_nil!.lat + @to_poi.not_nil!.lat) / 2.0,
      lon: (@from_poi.not_nil!.lon + @to_poi.not_nil!.lon) / 2.0
    )
    return p
  end

  def distance_center_point_to_home
    center_point.distance_to(TransportPoiEntity::HOME_POINT)
  end

  def time_cost_per_distance_center_km_in_hours
    transport_total_cost_hours / distance_center_point_to_home
  end

  def time_cost_per_distance_center_km_in_seconds
    time_cost_per_distance_center_km_in_hours * 3600.0
  end

  def train_start_cost_hours
    train_start_cost.to_f / 60.0
  end

  def train_end_cost_hours
    train_end_cost.to_f / 60.0
  end

end
