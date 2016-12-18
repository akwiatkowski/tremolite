require "./base_view"

class Tremolite::Views::PageView < Tremolite::Views::BaseView
  def initialize(@blog : Tremolite::Blog)
  end

  def image_path
    ""
  end

  def title
    ""
  end

  def subtitle
    ""
  end

  def inner_html
    ""
  end

  def content
    page_header_html +
      page_article_html
  end

  def page_header_html
    data = Hash(String, String).new
    data["post.image_url"] = image_path
    data["post.title"] = title
    data["post.subtitle"] = subtitle
    return load_view("page/header", data)
  end

  def page_article_html
    data = Hash(String, String).new
    data["content"] = inner_html
    return load_view("page/article", data)
  end
end