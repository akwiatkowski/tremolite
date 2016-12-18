require "./base_view"

class Tremolite::Views::LandView < Tremolite::Views::BaseView
  def initialize(@blog : Tremolite::Blog, @land : LandEntity)
  end

  def content
    land_header_html +
      land_article_html
  end

  def land_header_html
    data = Hash(String, String).new
    data["post.image_url"] = @land.image_url # TODO
    data["post.title"] = @land.name
    data["post.subtitle"] = @land.main
    return load_html("page/header", data)
  end

  def land_article_html
    content = ""
    data = Hash(String, String).new

    @blog.post_collection.each_post_from_latest do |post|
      if @land.belongs_to_post?(post)
        ph = Hash(String, String).new
        ph["post.url"] = post.url
        ph["post.title"] = post.title
        ph["post.subtitle"] = post.subtitle
        ph["post.date"] = post.date
        ph["post.author"] = post.author

        content += load_html("post/preview", ph)
        content += "\n"
      end
    end

    data["content"] = content
    return load_html("page/article", data)
  end
end
