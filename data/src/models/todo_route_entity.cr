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

  @through : Array(String)

  # loaded from other TrainCostEntity
  @transport_from_cost : Int32 # minutes of train ride from home to start
  @transport_to_cost : Int32 # minutes of train ride from end to home

  # some routes are `true external`, that means they are not sensible
  # without having set "external HQ" (accommodation)
  #
  # in this case stats related to train travel from HQ are not usable
  @train_return_time_cost : (Int32 | Nil)

  getter :voivodeship, :type, :distance, :time_length, :url, :desc_url, :from, :to, :through
  getter :transport_from_cost, :transport_to_cost
  getter :train_return_time_cost

  def initialize(y : YAML::Any, transport_pois : Array(TransportPoiEntity), @logger : Logger)
    @voivodeship = y["voivodeship"].to_s
    @type = y["type"].to_s
    @distance = y["distance"].to_s.to_f
    @time_length = y["time_length"].to_s.to_f
    @url = y["url"].to_s

    @through = Array(String).new

    @from = y["from"].to_s
    @to = y["to"].to_s

    t = transport_pois.select{|tc| tc.name == @from }
    if t.size > 0
      @from_poi = t.first.as(TransportPoiEntity)
      if @from_poi.not_nil!.with_train?
        # this place has working train connection
        @transport_from_cost = @from_poi.not_nil!.time_cost.not_nil!
      else
        @transport_from_cost = -1
      end
    else
      @logger.error("TodoRouteEntity: NOT FOUND FOR #{@from}".colorize(:red))
      @transport_from_cost = -1
      raise "TodoRouteEntity: NOT FOUND FOR #{@from}"
    end

    t = transport_pois.select{|tc| tc.name == @to }
    if t.size > 0
      @to_poi = t.first.as(TransportPoiEntity)
      if @to_poi.not_nil!.with_train?
        @transport_to_cost = @to_poi.not_nil!.time_cost.not_nil!
      else
        @transport_to_cost = -1
      end
    else
      @logger.error("TodoRouteEntity: NOT FOUND FOR #{@to}".colorize(:red))
      @transport_to_cost = -1
      raise "TodoRouteEntity: NOT FOUND FOR #{@to}"
    end

    @desc_url = y["desc_url"].to_s if y["desc_url"]?
    @train_return_time_cost = y["train_return_time_cost"].to_s.to_i if y["train_return_time_cost"]?

    if y["through"]?
      y["through"].each do |t|
        @through << t.to_s
      end
    end
  end

  # fast, close trips
  def close?
    transport_total_cost_minutes <= 150.0
  end

  # longer transport time costs
  def full_day?
    transport_total_cost_minutes > 150.0 && transport_total_cost_minutes <= 270.0
  end

  # accommodation is recommended
  def external?
    transport_total_cost_minutes > 270.0
  end

  # touring trips with panniers
  def touring?
    distance >= 120.0
  end

  def time_length_hours
    time_length
  end

  def transport_total_cost
    @transport_from_cost + @transport_to_cost
  end

  def transport_total_cost_minutes
    transport_total_cost.to_f
  end

  def transport_total_cost_hours
    transport_total_cost.to_f / 60.0
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

  def transport_from_cost_minutes
    transport_from_cost
  end

  def transport_from_cost_hours
    transport_from_cost.to_f / 60.0
  end

  def transport_to_cost_minutes
    transport_to_cost
  end

  def transport_to_cost_hours
    transport_to_cost.to_f / 60.0
  end

  def train_return_time_cost_hours
    return train_return_time_cost.not_nil! / 60.0
  end

  def train_return_time_cost_minutes
    return train_return_time_cost.not_nil!
  end

  def total_cost_external_accommodation
    return train_return_time_cost_hours + time_length.to_f
  end

  def time_length_minutes
    time_length * 60
  end

  def time_length_external_accommodation_percentage
    100.0 * time_length_hours / total_cost_external_accommodation
  end

end
