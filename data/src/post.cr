require "./models/poi_entity"

alias TremolitePostRouteObject = Hash(String, (String | Array(Array(Float64))))

class Tremolite::Post
  def custom_initialize
    @tags = Array(String).new
    @towns = Array(String).new
    @lands = Array(String).new
    @pois = Array(PoiEntity).new

    # yey, static typing
    @coords = Array(TremolitePostRouteObject).new

    @small_image_url = "/images/#{slug}/small/header.jpg"
    @thumb_image_url = "/images/#{slug}/thumb/header.jpg"

    @ext_image_url = String.new
  end

  getter :coords
  getter :small_image_url, :thumb_image_url
  getter :tags, :towns, :lands, :pois

  def custom_process_header
    if @header["coords"]?
      # TODO refactor to structure
      # easier to generate JSON
      coords = @header["coords"]
      coords.each do |ch|
        ro = TremolitePostRouteObject.new
        ro["type"] = ch["type"].to_s
        ro["route"] = Array(Array(Float64)).new

        ch["route"].each do |coord|
          ro["route"].as(Array) << [coord[0].to_s.to_f, coord[1].to_s.to_f]
        end

        @coords.not_nil! << ro
      end
    end

    # tags, towns and lands
    if @header["tags"]?
      @header["tags"].each do |tag|
        @tags.not_nil! << tag.to_s
      end
    end
    if @header["towns"]?
      @header["towns"].each do |town|
        @towns.not_nil! << town.to_s
      end
    end
    if @header["lands"]?
      @header["lands"].each do |land|
        @lands.not_nil! << land.to_s
      end
    end

    # pois
    if @header["pois"]? && "" == @header["pois"]?
      @header["pois"].each do |poi|
        @pois.not_nil! << PoiEntity.new(poi)
      end
    end

    # download previous external heade images locally
    # now we will only use local images
    @ext_image_url = @header["header-ext-img"].to_s # TODO
    download_header_image
  end

  def related_coords : Array(Tuple(Float64, Float64))
    cs = Array(Tuple(Float64, Float64)).new

    @pois.not_nil!.each do |p|
      cs << {p.lat, p.lon}
    end

    @coords.not_nil!.each do |ce|
      ce["route"].as(Array).each do |c|
        cs << {c[0], c[1]}
      end
    end

    return cs
  end

  def closest_to_point(lat : Float64, lon : Float64)
    cs = related_coords
    cs = cs.sort{ |a,b|
      da = (a[0] - lat) ** 2 + (a[1] - lon) ** 2
      db = (b[0] - lat) ** 2 + (b[1] - lon) ** 2
      da <=> db
    }

    if cs.size > 0
      return cs.last
    else
      return nil
    end
  end

  def closest_distance_to_point(lat : Float64, lon : Float64)
    p = closest_to_point(lat: lat, lon: lon)
    if p
      cp = CrystalGpx::Point.new(lat: p[0], lon: p[1])
      d = cp.distance_to(other_lat: lat, other_lon: lon)
      # puts "#{d}: #{lat}, #{lon} - #{p[0]}, #{p[1]}"
      return d
    else
      return nil
    end
  end

  # temporary download external image as title
  private def download_header_image
    img_url = File.join(["data", @image_url])
    if @ext_image_url != "" && false == File.exists?(img_url)
      ImageResizer.download_image(source: @ext_image_url.not_nil!, output: img_url)
    end
  end
end
