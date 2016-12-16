require "markdown"
require "yaml"

require "../std/markdown/parser" # hotfix for Crystal std lib

class Tremolite::Post
  alias TremolitePostRouteObject = Hash(String, (String | Array(Array(Float64)) ))

  def initialize(@path : String)
    @content_string = String.new
    @content_html = String.new
    @header = YAML::Any.new(nil)

    @slug = (File.basename(@path)).gsub(/\..{1,10}$/, "").as(String)
    @title = String.new
    @subtitle = String.new
    @author = String.new
    @category = String.new
    @time = Time.epoch(0)

    @html_output_path = String.new
    @dir_path = String.new
    @url = String.new

    @tags = Array(String).new
    @towns = Array(String).new
    @lands = Array(String).new

    # yey, static typing
    @coords = Array(TremolitePostRouteObject).new

    @image_url = "/images/#{slug}/header.jpg"
    @small_image_url = "/images/#{slug}/small/header.jpg"
    @thumb_image_url = "/images/#{slug}/thumb/header.jpg"

    @ext_image_url = String.new
  end

  getter :content_string, :content_html, :header
  getter :html_output_path, :dir_path, :url

  # from header or filename
  getter :title, :subtitle, :author, :slug, :time, :category, :coords
  getter :image_url, :small_image_url, :thumb_image_url
  getter :tags, :towns, :lands

  def date
    @time.to_s("%Y-%m-%d")
  end

  # end of header getters

  def parse
    s = File.read(@path)

    header_idxs = Array(Int32).new

    s.lines.each_with_index do |line, i|
      if line =~ /\-{3,100}/
        header_idxs << i
      end
    end

    if header_idxs.size >= 2
      header_string = s.lines[(header_idxs[0] + 1)...(header_idxs[1])].join("")
      @header = YAML.parse(header_string)

      @content_string = s.lines[(header_idxs[1] + 1)..(-1)].join("")
      @content_html = Markdown.to_html(@content_string)

      # is valid, process rest
      process
    else
      return nil
    end
  end

  private def process
    process_header
    process_paths
  end

  private def process_header
    @title = @header["title"].to_s
    @subtitle = @header["subtitle"].to_s
    @author = @header["author"].to_s
    @category = @header["categories"].to_s
    @time = Time.parse(time: @header["date"].to_s, pattern: "%Y-%m-%d %H:%M:%S", kind: Time::Kind::Local)

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

        @coords << ro
      end
    end

    # tags, towns and lands
    if @header["tags"]?
      @header["tags"].each do |tag|
        @tags << tag.to_s
      end
    end
    if @header["towns"]?
      @header["towns"].each do |town|
        @towns << town.to_s
      end
    end
    if @header["lands"]?
      @header["lands"].each do |land|
        @lands << land.to_s
      end
    end

    # download previous external heade images locally
    # now we will only use local images
    @ext_image_url = @header["header-ext-img"].to_s # TODO
    download_header_image
  end

  private def process_paths
    @url = "/" + File.join([@category.to_s, @slug])
    @html_output_path = Tremolite::Renderer.convert_url_to_local_path_with_public(@url)
    @dir_path = File.dirname(@html_output_path)
  end

  # temporary download external image as title
  private def download_header_image
    img_url = File.join(["data", @image_url])
    if @ext_image_url != "" && false == File.exists?(img_url)
      Dir.mkdir_p_dirname(img_url)
      command = "wget \"#{@ext_image_url}\" -O \"#{img_url}\" "
      `#{command}`
    end
  end
end
