class PostView < BaseView
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
    return load_html("post/header", data)
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
      nl = load_html("post/pager_next", nd)
      data["next_post_pager"] = nl
    end

    pp = @blog.post_collection.prev_to(@post)
    if pp
      pd = Hash(String, String).new
      pd["post.url"] = pp.url
      pd["post.title"] = pp.title
      pl = load_html("post/pager_prev", pd)
      data["prev_post_pager"] = pl
    end

    # tags
    pd = Hash(String, String).new
    pd["taggable.name"] = "Tagi"
    pd["taggable.content"] = ""
    links = Array(String).new
    @post.tags.not_nil!.each do |tag|
      @blog.data_manager.not_nil!.tags.not_nil!.each do |tag_entity|
        if tag == tag_entity.slug
          links << "<a href=\"" + tag_entity.url + "\">" + tag_entity.name + "</a>"
        end
      end
    end
    if links.size > 0
      pd["taggable.content"] = links.join(", ")
      taggable_content = load_html("post/taggable", pd)
      data["tags_content"] = taggable_content
    else
      data["tags_content"] = ""
    end

    # lands
    pd = Hash(String, String).new
    pd["taggable.name"] = "Krainy"
    pd["taggable.content"] = ""
    links = Array(String).new
    @post.lands.not_nil!.each do |land|
      @blog.data_manager.not_nil!.lands.not_nil!.each do |land_entity|
        if land == land_entity.slug
          links << "<a href=\"" + land_entity.url + "\">" + land_entity.name + "</a>"
        end
      end
    end
    if links.size > 0
      pd["taggable.content"] = links.join(", ")
      taggable_content = load_html("post/taggable", pd)
      data["lands_content"] = taggable_content
    else
      data["lands_content"] = ""
    end

    # towns
    pd = Hash(String, String).new
    pd["taggable.name"] = "Miejscowości"
    pd["taggable.content"] = ""
    links = Array(String).new
    @post.towns.not_nil!.each do |town|
      @blog.data_manager.not_nil!.towns.not_nil!.each do |town_entity|
        if town == town_entity.slug
          links << "<a href=\"" + town_entity.url + "\">" + town_entity.name + "</a>"
        end
      end
    end
    if links.size > 0
      pd["taggable.content"] = links.join(", ")
      taggable_content = load_html("post/taggable", pd)
      data["towns_content"] = taggable_content
    else
      data["towns_content"] = ""
    end

    # pois
    if @post.pois.not_nil!.size > 0
      pd = Hash(String, String).new
      pd["pois_list"] = @post.pois.not_nil!.map { |p| p.wrapped_link }.join("")
      pois_container = load_html("post/pois", pd)
      data["pois_container"] = pois_container
    else
      data["pois_container"] = ""
    end

    return load_html("post/article", data)
  end
end
