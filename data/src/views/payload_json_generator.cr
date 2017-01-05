require "json"

class PayloadJsonGenerator
  def initialize(@blog : Tremolite::Blog, @url : String)
  end

  getter :url

  def to_json
    result = String.build do |io|
      io.json_object do |root|
        root.field "posts" do
          io.json_array do |posts|
            @blog.post_collection.posts.each do |post|
              posts << {
                "url"            => post.url,
                "slug"           => post.slug,
                "title"          => post.title,
                "category"       => post.category,
                "date"           => post.date,
                "year"           => post.time.year,
                "month"          => post.time.month,
                "day"            => post.time.day,
                "header-ext-img" => post.image_url,
                "image_url"      => post.image_url,
                "coords"         => post.coords,
                "tags"           => post.tags,
                "towns"          => post.towns,
                "lands"          => post.lands,
              }
            end
          end
        end

        root.field "towns" do
          io.json_array do |towns|
            @blog.data_manager.not_nil!.towns.not_nil!.each do |town|
              towns << {
                "url"            => town.url,
                "slug"           => town.slug,
                "name"           => town.name,
                "image_url"      => town.image_url,
                "header-ext-img" => town.image_url,
                "voivodeship"    => town.voivodeship,
                "inside"         => town.voivodeship,
              }
            end
          end
        end

        root.field "voivodeships" do
          io.json_array do |voivodeships|
            @blog.data_manager.not_nil!.voivodeships.not_nil!.each do |voivodeship|
              voivodeships << {
                "url"            => voivodeship.url,
                "slug"           => voivodeship.slug,
                "name"           => voivodeship.name,
                "image_url"      => voivodeship.image_url,
                "header-ext-img" => voivodeship.image_url,
              }
            end
          end
        end

        root.field "tags" do
          io.json_array do |tags|
            @blog.data_manager.not_nil!.tags.not_nil!.each do |tag|
              tags << {
                "url"            => tag.url,
                "slug"           => tag.slug,
                "name"           => tag.name,
                "image_url"      => tag.image_url,
                "header-ext-img" => tag.image_url,
              }
            end
          end
        end

        root.field "lands" do
          io.json_array do |lands|
            @blog.data_manager.not_nil!.lands.not_nil!.each do |land|
              lands << {
                "url"               => land.url,
                "slug"              => land.slug,
                "name"              => land.name,
                "image_url"         => land.image_url,
                "header-ext-img"    => land.image_url,
                "country"           => land.country,
                "visited"           => land.visited,
                "type"              => land.type,
                "train_time_poznan" => land.train_time_poznan,
              }
            end
          end
        end

        root.field "land_types" do
          io.json_array do |land_types|
            @blog.data_manager.not_nil!.land_types.not_nil!.each do |land_type|
              land_types << {
                "slug" => land_type.slug,
                "name" => land_type.name,
              }
            end
          end
        end
      end
    end

    return result
  end
end
