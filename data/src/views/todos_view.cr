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

      if todo_route.train_start_cost > 0
        data["route.from_cost"] = "#{todo_route.train_start_cost} min = #{todo_route.train_start_cost_hours.round(1)} h"
      else
        data["route.from_cost"] = ""
      end

      data["route.to_cost"] = todo_route.to
      if todo_route.train_end_cost > 0
        data["route.to_cost"] = "#{todo_route.train_end_cost} min = #{todo_route.train_end_cost_hours.round(1)} h"
      else
        data["route.to_cost"] = ""
      end

      data["route.distance"] = todo_route.distance.to_i.to_s
      data["route.time_length"] = todo_route.time_length.to_i.to_s
      data["route.total_cost"] = todo_route.total_cost_hours.to_i.to_s

      total_cost_explained = ""
      if todo_route.train_start_cost > 0 || todo_route.train_end_cost > 0
        total_cost_explained += " = "
        if todo_route.train_start_cost > 0
          total_cost_explained += "#{todo_route.train_start_cost}min + "
        end
        total_cost_explained += "#{(todo_route.time_length * 60.0).to_i}min"
        if todo_route.train_end_cost > 0
          total_cost_explained += " + #{todo_route.train_end_cost}min"
        end
      end
      data["route.total_cost_explained"] = total_cost_explained

      data["route.time_length_percentage"] = todo_route.time_length_percentage.to_i.to_s
      data["route.straight_line_length"] = todo_route.straight_line_length.to_i.to_s
      data["route.distance_to_straigh_percentage"] = todo_route.distance_to_straigh_percentage.to_i.to_s
      data["route.center_point_distance_to_home"] = todo_route.distance_center_point_to_home.to_i.to_s
      data["route.time_cost_per_distance_center_km_in_seconds"] = todo_route.time_cost_per_distance_center_km_in_seconds.to_i.to_s


      todo_routes_string += load_html("todo_route_item", data)
      todo_routes_string += "\n"
    end

    return todo_routes_string
  end
end
