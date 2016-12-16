require "./base_view"

class Tremolite::Views::TagView < Tremolite::Views::BaseView
  def initialize(@blog : Tremolite::Blog, @tag : TagEntity)
  end

  def content
    post_header_html +
      post_article_html
  end

  def post_header_html
    data = Hash(String, String).new
    data["post.image_url"] = @tag.image_path # TODO
    data["post.title"] = @tag.name
    data["post.subtitle"] = ""
    return load_view("page/header", data)
  end

  def post_article_html
    content = ""
    data = Hash(String, String).new

    @blog.post_collection.each_post_from_latest do |post|
      if @tag.belongs_to_post?(post)
        ph = Hash(String, String).new
        ph["post.url"] = post.url
        ph["post.title"] = post.title
        ph["post.subtitle"] = post.subtitle
        ph["post.date"] = post.date
        ph["post.author"] = post.author

        content += load_view("post/preview", ph)
        content += "\n"
      end
    end

    data["content"] = content
    return load_view("page/article", data)
  end
end
