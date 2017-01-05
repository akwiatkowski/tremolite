class HomeView < BaseView
  def initialize(@blog : Tremolite::Blog)
    @show_only_count = 8
  end

  def title
    @blog.data_manager.not_nil!["site.title"]
  end

  def content
    data = Hash(String, String).new

    boxes = ""
    count = 0

    @blog.post_collection.each_post_from_latest do |post|
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
