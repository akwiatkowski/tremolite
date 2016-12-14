class Tremolite::ImageResizer
  @@sizez = {
    "small" => {width: 600, height: 400, quality: 65},
    "thumb" => {width: 60, height: 40, quality: 70},
  }
  @@quality = 70

  def initialize(@blog : Tremolite::Blog)
    @data_path = @blog.data_path.as(String)
    @logger = @blog.logger.as(Logger)
    @flags = "-strip -interlace Plane"
  end

  def resize_all_images_for_post(post : Tremolite::Post)
    resize_for_post(post, name: "header.jpg")
  end

  def resize_for_post(post : Tremolite::Post, name = "header.jpg")
    img_url = File.join(["data", "images", post.slug, name])
    if File.exists?(img_url)
      # there are defined sizes of output images
      @@sizez.each do |prefix, resolution|
        resize_image(
          path: img_url,
          width: resolution[:width],
          height: resolution[:height],
          output: File.join(["data", "images", post.slug, prefix, name]),
          quality: resolution[:quality]
        )
      end
    end
  end

  def resize_image(
                   path : String,
                   width : Int32,
                   height : Int32,
                   output : String,
                   quality = 70)
    Dir.mkdir_p_dirname(output)

    magik_resize = "#{width}x#{height}"
    resized_quality_flag = "-quality #{quality}"
    command = "convert #{@flags} #{resized_quality_flag} -resize #{magik_resize} \"#{path}\" \"#{output}\""
    puts command

    `#{command}`
  end
end
