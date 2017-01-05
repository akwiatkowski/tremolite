class MapView < BaseView
  def initialize(@blog : Tremolite::Blog)
  end

  def content
    data = Hash(String, String).new
    data["header_img"] = @blog.data_manager.not_nil!["map.backgrounds"].as(String)
    load_html("map", data)
  end
end
