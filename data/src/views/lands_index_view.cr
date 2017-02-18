class LandsIndexView < PageView
  def initialize(@blog : Tremolite::Blog, @url : String)
    @image_url = @blog.data_manager.not_nil!["lands.backgrounds"].as(String)
    @title = @blog.data_manager.not_nil!["lands.title"].as(String)
    @subtitle = @blog.data_manager.not_nil!["lands.subtitle"].as(String)
  end

  getter :image_url, :title, :subtitle

  def inner_html
    s = "<ol>"

    @blog.data_manager.not_nil!.land_types.not_nil!.each do |land_type|
      s += "<li>\n<h2>#{land_type.name}</h2>\n"
      s += "<ol>\n"

      @blog.data_manager.not_nil!.lands.not_nil!.select { |l| l.type == land_type.slug }.each do |land|
        s += land_element(land)
      end

      s += "</ol></li>\n"
    end

    return s
  end

  def land_element(land)
    s = "<li><a href=\"#{land.url}\">#{land.name}</a>"
    s += "</li>\n"
    return s
  end
end
