require "./base_view"

class Tremolite::Views::TownView < Tremolite::Views::BaseView
  def initialize(@blog : Tremolite::Blog, @town : TownEntity)
  end

  def content
    town_header_html +
      town_article_html
  end

  def town_header_html
    data = Hash(String, String).new
    data["post.image_url"] = @town.image_url # TODO
    data["post.title"] = @town.name
    data["post.subtitle"] = ""
    return load_html("page/header", data)
  end

  def town_article_html
    content = ""
    data = Hash(String, String).new

    @blog.post_collection.each_post_from_latest do |post|
      if @town.belongs_to_post?(post)
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
