class TodosView < PageView
  def initialize(@blog : Tremolite::Blog, @todos : Array(TodoRouteEntity))
    @image_path = @blog.data_manager.not_nil!["todos.backgrounds"].as(String)
    @title = @blog.data_manager.not_nil!["todos.title"].as(String)
    @subtitle = @blog.data_manager.not_nil!["todos.subtitle"].as(String)
  end

  getter :image_path, :title, :subtitle

  def inner_html
    todo_routes_string = ""

    @todos.each do |todo_route|
      data = Hash(String, String).new
      data["route.from"] = todo_route.from
      data["route.to"] = todo_route.to
      data["route.url"] = todo_route.url

      if todo_route.transport_from_cost_minutes > 0
        data["route.from_cost"] = "#{todo_route.transport_from_cost_minutes} min = #{todo_route.transport_from_cost_hours.round(1)} h"
      else
        data["route.from_cost"] = ""
      end

      if todo_route.transport_to_cost_minutes > 0
        data["route.to_cost"] = "#{todo_route.transport_to_cost_minutes} min = #{todo_route.transport_to_cost_hours.round(1)} h"
      else
        data["route.to_cost"] = ""
      end

      data["route.distance"] = todo_route.distance.to_i.to_s
      data["route.time_length"] = todo_route.time_length.to_i.to_s
      data["route.total_cost"] = todo_route.total_cost_hours.to_i.to_s

      total_cost_explained = ""
      if todo_route.transport_from_cost_minutes > 0 || todo_route.transport_to_cost_minutes > 0
        total_cost_explained += " = "
        if todo_route.transport_from_cost_minutes > 0
          total_cost_explained += "#{todo_route.transport_from_cost_minutes}min + "
        end
        total_cost_explained += "#{todo_route.time_length_minutes.to_i}min"
        if todo_route.transport_to_cost_minutes > 0
          total_cost_explained += " + #{todo_route.transport_to_cost_minutes}min"
        end
      end
      data["route.total_cost_explained"] = total_cost_explained

      data["route.time_length_percentage"] = todo_route.time_length_percentage.to_i.to_s
      data["route.straight_line_length"] = todo_route.straight_line_length.to_i.to_s
      data["route.distance_to_straigh_percentage"] = todo_route.distance_to_straigh_percentage.to_i.to_s
      data["route.center_point_distance_to_home"] = todo_route.distance_center_point_to_home.to_i.to_s
      data["route.time_cost_per_distance_center_km_in_seconds"] = todo_route.time_cost_per_distance_center_km_in_seconds.to_i.to_s

      # with accommodation
      data["route.total_cost_external_accommodation"] = "N/A "
      data["route.total_cost_external_accommodation_explained"] = ""
      data["route.time_length_external_accommodation_percentage"] = "N/A "
      data["partial.accommodation"] = ""
      # only if this is set
      if todo_route.train_return_time_cost
        data["route.total_cost_external_accommodation"] = todo_route.total_cost_external_accommodation.not_nil!.round(1).to_s
        data["route.total_cost_external_accommodation_explained"] = "#{todo_route.train_return_time_cost_minutes}min + #{todo_route.time_length_minutes}min"
        data["route.time_length_external_accommodation_percentage"] = todo_route.time_length_external_accommodation_percentage.to_i.to_s
        # render partial
        data["partial.accommodation"] = load_html("todo_route_accommodation", data)
      end

      if todo_route.through.size > 0
        data["partial.through"] = load_html("todo_route_through", {"route.through" => todo_route.through.join(", ")} )
      else
        data["partial.through"] = ""
      end

      todo_routes_string += load_html("todo_route_item", data)
      todo_routes_string += "\n"
    end

    return todo_routes_string
  end
end
