require "./base_view"

class Tremolite::Views::PostView < Tremolite::Views::BaseView
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
    return load_view("post/header", data)
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
      nl = load_view("post/pager_next", nd)
      data["next_post_pager"] = nl
    end

    pp = @blog.post_collection.prev_to(@post)
    if pp
      pd = Hash(String, String).new
      pd["post.url"] = pp.url
      pd["post.title"] = pp.title
      pl = load_view("post/pager_prev", pd)
      data["prev_post_pager"] = pl
    end

    # tags
    pd = Hash(String, String).new
    pd["taggable.name"] = "Tagi"
    pd["taggable.content"] = ""

    # tags
    links = Array(String).new
    @post.tags.each do |tag|
      @blog.data_manager.not_nil!.tags.each do |tag_entity|
        if tag == tag_entity.slug
          links << "<a href=\"" + tag_entity.url + "\">" + tag_entity.name + "</a>"
        end
      end
    end
    if links.size > 0
      pd["taggable.content"] = links.join(", ")
      taggable_content = load_view("post/taggable", pd)
      data["tags_content"] = taggable_content
    else
      data["tags_content"] = ""
    end

    return load_view("post/article", data)
  end
end
