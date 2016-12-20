class MapView < BaseView
  def initialize(@blog : Tremolite::Blog)
  end

  def content
    data = Hash(String, String).new
    data["header_img"] = ""
    load_html("map", data)
  end
end
