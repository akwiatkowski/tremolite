struct LandEntity
  @slug : String
  @name : String
  @header_ext_img : String
  @main : String
  @country : String
  @type : String
  @visited : (Time | Nil)
  @train_time_poznan : (Int32 | Nil)
  @near : Array(String)

  getter :name, :slug, :header_ext_img

  def initialize(y : YAML::Any)
    @slug = y["slug"].to_s
    @name = y["name"].to_s
    @header_ext_img = y["header-ext-img"].to_s
    @main = y["main"].to_s
    @country = y["country"].to_s
    @type = y["type"].to_s

    if y["train_time_poznan"]?
      @train_time_poznan = y["train_time_poznan"].to_s.to_i
    end

    @near = Array(String).new
    if y["near"]?
      y["near"].each do |n|
        @near << n.to_s
      end
    end
    if y["visited"]?
      @visited = Time.parse(y["visited"].to_s, "%Y-%m")
    end
  end

  def url
    "/land/#{@slug}"
  end
end
