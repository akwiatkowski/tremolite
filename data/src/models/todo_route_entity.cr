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

  @time_cost_from_entity : (TransportPoiEntity | Nil)
  @time_cost_to_entity : (TransportPoiEntity | Nil)

  # loaded from other TrainCostEntity
  @train_start_cost : Int32 # minutes of train ride from home to start
  @train_end_cost : Int32 # minutes of train ride from end to home

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
      @time_cost_from_entity = t.first.as(TransportPoiEntity)
      @train_start_cost = @time_cost_from_entity.not_nil!.time_cost
    else
      @logger.error("TodoRouteEntity: NOT FOUND FOR #{@from}".colorize(:red))
      @train_start_cost = -1
      raise "TodoRouteEntity: NOT FOUND FOR #{@from}"
    end

    t = transport_pois.select{|tc| tc.name == @to }
    if t.size > 0
      @time_cost_to_entity = t.first.as(TransportPoiEntity)
      @train_end_cost = @time_cost_to_entity.not_nil!.time_cost
    else
      @logger.error("TodoRouteEntity: NOT FOUND FOR #{@to}".colorize(:red))
      @train_end_cost = -1
      raise "TodoRouteEntity: NOT FOUND FOR #{@to}"
    end

    @desc_url = y["desc_url"].to_s if y["desc_url"]?
  end

  def time_length_hours
    time_length
  end

  def train_total_cost
    @train_start_cost + @train_end_cost
  end

  def train_total_cost_hours
    train_total_cost.to_f / 60.0
  end

  def total_cost_hours
    train_total_cost_hours.to_f + time_length.to_f
  end

  def time_length_percentage
    100.0 * time_length_hours / total_cost_hours
  end

end
