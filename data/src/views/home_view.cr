class HomeView < BaseView
  def initialize(@blog : Tremolite::Blog, @url = "/")
    @show_only_count = 8
  end

  def title
    @blog.data_manager.not_nil!["site.title"]
  end

  def meta_keywords_string
    "turystyka, rower, zwiedzanie, Polska, trasa, góry, odkryj, szlak, okolica, wieś, zdjęcia, fotografia, krajobraz"
  end

  def meta_description_string
    site_desc
  end

  def page_desc
    site_desc
  end

  def content
    data = Hash(String, String).new

    boxes = ""
    count = 0

    # only non-todo, and main tagged posts
    posts = @blog.post_collection.posts.select{|p| (p.tags.not_nil!.includes?("todo") == false) && (p.tags.not_nil!.includes?("main") == true) }
    # sorted by date descending
    posts = posts.sort{|a,b| b.time <=> a.time }

    posts.each do |post|
      ph = Hash(String, String).new
      ph["klass"] = @show_only_count >= count ? "" : "hidden"
      ph["post.url"] = post.url
      ph["post.small_image_url"] = post.small_image_url.not_nil!
      ph["post.title"] = post.title
      ph["post.date"] = post.date

      boxes += load_html("post/box", ph)
      boxes += "\n"

      count += 1
    end

    data["postbox"] = boxes
    return load_html("home", data)
  end
end
