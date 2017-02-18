class TownsIndexView < PageView
  def initialize(@blog : Tremolite::Blog, @url : String)
    @image_url = @blog.data_manager.not_nil!["towns.backgrounds"].as(String)
    @title = @blog.data_manager.not_nil!["towns.title"].as(String)
    @subtitle = @blog.data_manager.not_nil!["towns.subtitle"].as(String)
  end

  getter :image_url, :title, :subtitle

  def inner_html
    s = "<ol>"

    @blog.data_manager.not_nil!.voivodeships.not_nil!.each do |voivodeship|
      s += "<li>\n<h2>#{voivodeship.name}</h2>\n"
      s += "<ol>\n"

      @blog.data_manager.not_nil!.towns.not_nil!.select { |t| t.voivodeship == voivodeship.slug }.each do |town|
        s += town_element(town)
      end

      s += "</ol></li>\n"
    end

    return s
  end

  def town_element(town)
    s = "<li><a href=\"#{town.url}\">#{town.name}</a>"

    if town.lat && town.lon
      # s += "<a class=\"small\" href"
      ump_link = "http://mapa.ump.waw.pl/ump-www/?zoom=13&lat=#{town.lat}&lon=#{town.lon}&layers=B000000FFFFTFF&mlat=#{town.lat}&mlon=#{town.lon}"
      s += " <a href=\"#{ump_link}\"><span class=\"small glyphicon glyphicon-map-marker\"></span></a>"
    end

    s += "</li>\n"
    return s
  end
end
