require "json"

class Tremolite::Views::PayloadJson
  def initialize(@blog : Tremolite::Blog)
  end

  def to_json
    result = String.build do |io|
      io.json_object do |root|
        root.field "posts" do
          io.json_array do |posts|
            @blog.post_collection.posts.each do |post|
              posts << {
                "url" => post.url,
                "slug" => post.slug,
                "title" => post.title,
                "category" => post.category,
                "date" => post.date,
                "year" => post.time.year,
                "month" => post.time.month,
                "day" => post.time.day,
                "header-ext-img" => post.image_url,
                "coords" => post.coords,
                "tags" => post.tags,
                "towns" => post.towns,
                "lands" => post.lands
              }
            end
          end
        end
      end
    end

    return result
  end
end
