require "./site_layout"

class Tremolite::Layouts::PostLayout < Tremolite::Layouts::SiteLayout
  def initialize(@blog : Tremolite::Blog, @post : Tremolite::Post)
  end

  def content
    post_header_html +
      post_article_html
  end

  def post_header_html
    data = Hash(String, String).new
    data["post.image_url"] = @post.image_url
    data["post.title"] = @post.title
    data["post.subtitle"] = @post.subtitle
    data["post.author"] = @post.author
    data["post.date"] = @post.date
    return load_layout("post/header", data)
  end

  def post_article_html
    data = Hash(String, String).new
    data["content"] = @post.content_html
    # if not used should be set to blank
    data["next_post_pager"] = ""
    data["prev_post_pager"] = ""

    np = @blog.post_collection.next_to(@post)
    if np
      nd = Hash(String, String).new
      nd["post.url"] = np.url
      nd["post.title"] = np.title
      nl = load_layout("post/pager_next", nd)
      data["next_post_pager"] = nl
    end

    pp = @blog.post_collection.prev_to(@post)
    if pp
      pd = Hash(String, String).new
      pd["post.url"] = pp.url
      pd["post.title"] = pp.title
      pl = load_layout("post/pager_prev", pd)
      data["prev_post_pager"] = pl
    end

    return load_layout("post/article", data)
  end
end
