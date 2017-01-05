class SummaryView < PageView
  def initialize(@blog : Tremolite::Blog, @url : String)
    @image_path = @blog.data_manager.not_nil!["summary.backgrounds"].as(String)
    @title = @blog.data_manager.not_nil!["summary.title"].as(String)
    @subtitle = @blog.data_manager.not_nil!["summary.subtitle"].as(String)
  end

  getter :image_path, :title, :subtitle

  def inner_html
    posts_string = ""

    @blog.post_collection.posts.each do |post|
      data = Hash(String, String).new
      data["post.url"] = post.url
      data["post.date"] = post.date
      data["post.title"] = post.title
      data["post.subtitle"] = post.subtitle
      posts_string += load_html("summary_item", data)
      posts_string += "\n"
    end

    data = Hash(String, String).new
    data["summary.content"] = posts_string
    load_html("summary", data)
  end
end
