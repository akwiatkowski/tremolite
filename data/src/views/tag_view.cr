class TagView < BaseView
  def initialize(@blog : Tremolite::Blog, @tag : TagEntity)
  end

  def title
    @tag.name
  end

  def content
    tag_header_html +
      tag_article_html
  end

  def tag_header_html
    data = Hash(String, String).new
    data["post.image_url"] = @tag.image_url # TODO
    data["post.title"] = @tag.name
    data["post.subtitle"] = ""
    return load_html("page/header", data)
  end

  def tag_article_html
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

        content += load_html("post/preview", ph)
        content += "\n"
      end
    end

    data["content"] = content
    return load_html("page/article", data)
  end
end
