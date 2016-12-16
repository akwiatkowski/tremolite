require "./base_view"

class Tremolite::Views::MapView < Tremolite::Views::BaseView
  def initialize(@blog : Tremolite::Blog)
  end

  def content
    data = Hash(String, String).new
    data["header_img"] = ""
    load_view("map", data)
  end
end
