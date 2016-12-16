require "./base_view"

class Tremolite::Views::HomeView < Tremolite::Views::BaseView
  def initialize(@blog : Tremolite::Blog)
    @show_only_count = 8
  end

  def content
    data = Hash(String, String).new

    boxes = ""
    count = 0

    @blog.post_collection.each_post_from_latest do |post|
      ph = Hash(String, String).new
      ph["klass"] = @show_only_count >= count ? "" : "hidden"
      ph["post.url"] = post.url
      ph["post.small_image_url"] = post.small_image_url
      ph["post.title"] = post.title
      ph["post.date"] = post.date

      boxes += load_view("post/box", ph)
      boxes += "\n"

      count += 1
    end

    data["postbox"] = boxes
    return load_view("home", data)
  end
end
