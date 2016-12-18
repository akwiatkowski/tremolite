struct TagEntity
  @slug : String
  @name : String
  @header_ext_img : String

  getter :name, :slug, :header_ext_img

  def initialize(y : YAML::Any)
    @slug = y["slug"].to_s
    @name = y["name"].to_s
    @header_ext_img = y["header-ext-img"].to_s
  end

  def url
    "/tag/#{@slug}"
  end

  def image_url
    File.join(["/", "images", "tag", @slug + ".jpg"])
  end

  def belongs_to_post?(post : Tremolite::Post)
    post.tags.includes?(@slug)
  end
end
