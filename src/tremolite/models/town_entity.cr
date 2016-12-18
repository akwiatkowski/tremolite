require "yaml"

alias TownEntityHash = Hash(String, String | Array(String))

struct TownEntity
  @slug : String
  @name : String
  @type : String
  @header_ext_img : String

  @voivodeship : String | Nil

  getter :name, :slug, :voivodeship, :header_ext_img

  def initialize(y : YAML::Any)
    @slug = y["slug"].to_s
    @name = y["name"].to_s
    @type = y["type"].to_s

    @header_ext_img = y["header-ext-img"].to_s

    if y["inside"]?
      @voivodeship = y["inside"][0].to_s
    end

    @voivodeship = y["voivodeship"].to_s if y["voivodeship"]?
  end

  def to_hash
    h = TownEntityHash.new
    h["slug"] = @slug.to_s unless @slug.nil?
    h["name"] = @name.to_s unless @name.nil?
    h["header-ext-img"] = @header_ext_img.to_s unless @header_ext_img.nil?
    h["type"] = @type.to_s unless @type.nil?
    h["voivodeship"] = @voivodeship.to_s unless @voivodeship.nil?

    return h
  end

  def is_town?
    return @type == "town"
  end

  def is_voivodeship?
    return @type == "voivodeship"
  end

  def url
    "/town/#{@slug}"
  end

  def image_url
    File.join(["/", "images", "town", @slug + ".jpg"])
  end

  def belongs_to_post?(post : Tremolite::Post)
    post.towns.includes?(@slug)
  end
end
