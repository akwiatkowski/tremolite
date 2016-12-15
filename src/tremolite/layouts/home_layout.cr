require "./site_layout"

class Tremolite::Layouts::HomeLayout < Tremolite::Layouts::SiteLayout
  def initialize(@blog : Tremolite::Blog)
  end

  def content
    data = Hash(String, String).new

    boxes = ""

    @blog.post_collection.posts.each do |post|
      ph = Hash(String, String).new
      ph["klass"] = "" # "hidden"
      ph["post.url"] = post.url
      ph["post.small_image_url"] = post.small_image_url
      ph["post.title"] = post.title
      ph["post.date"] = post.date

      boxes += load_layout("post/box", ph)
      boxes += "\n"
    end

    data["postbox"] = boxes
    return load_layout("home", data)
  end

end
