class TodosView < PageView
  def initialize(@blog : Tremolite::Blog)
    @image_path = @blog.data_manager.not_nil!["todos.backgrounds"].as(String)
    @title = @blog.data_manager.not_nil!["todos.title"].as(String)
    @subtitle = @blog.data_manager.not_nil!["todos.subtitle"].as(String)
  end

  getter :image_path, :title, :subtitle

  def inner_html
    todo_routes_string = ""

    @blog.data_manager.not_nil!.todo_routes.not_nil!.each do |todo_route|
      data = Hash(String, String).new
      data["route.from"] = todo_route.from
      data["route.to"] = todo_route.to
      todo_routes_string += load_html("todo_route_item", data)
      todo_routes_string += "\n"
    end

    return todo_routes_string
  end
end
