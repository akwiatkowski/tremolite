require "./site_layout"

class Tremolite::Layouts::MapLayout < Tremolite::Layouts::SiteLayout
  def initialize(@blog : Tremolite::Blog)
  end

  def content
    data = Hash(String, String).new
    data["header_img"] = ""
    load_layout("map", data)
  end
end
