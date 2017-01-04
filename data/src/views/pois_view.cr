class PoisView < PageView
  def initialize(@blog : Tremolite::Blog)
    @image_path = @blog.data_manager.not_nil!["pois.backgrounds"].as(String)
    @title = @blog.data_manager.not_nil!["pois.title"].as(String)
    @subtitle = @blog.data_manager.not_nil!["pois.subtitle"].as(String)
  end

  getter :image_path, :title, :subtitle

  def inner_html
    posts_content = ""

    @blog.post_collection.posts_from_latest.each do |post|
      pois_content = ""
      post.pois.not_nil!.each do |poi|
        pois_content += load_html("pois/poi", {
          "zoom" => 13.to_s,
          "lat" => poi.lat.to_s,
          "lon" => poi.lon.to_s,
          "desc" => poi.name
          })
        pois_content += "\n"
      end

      # ignore posts without pois
      if pois_content.size > 0
        posts_content += load_html("pois/post", {
          "post.url" => post.url,
          "post.date" => post.date,
          "post.title" => post.title,
          "post.pois" => pois_content
          })
        posts_content += "\n"
      end
    end


    di = {
      "pois.content" => posts_content
    }

    return load_html("pois/index", di)
  end
end
