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

  def resize_all_images_for_post(post : Tremolite::Post, overwrite : Bool)
    # iterate by all images in proper direcory
    path = File.join(["data", "images", post.slug])
    Dir.entries(path).each do |name|
      if false == File.directory?(File.join([path, name]))
        resize_for_post(post: post, name: name, overwrite: overwrite)
      end
    end
  end

  def resize_all_images_for_post(post : Tremolite::Post, overwrite : Bool)
    # iterate by all images in proper direcory
    path = File.join(["data", "images", post.slug])
    Dir.entries(path).each do |name|
      if false == File.directory?(File.join([path, name]))
        resize_for_post(post: post, name: name, overwrite: overwrite)
      end
    end
  end

  def resize_for_post(post : Tremolite::Post, overwrite : Bool, name = "header.jpg")
    img_url = File.join(["data", "images", post.slug, name])
    if File.exists?(img_url)
      # there are defined sizes of output images
      @@sizez.each do |prefix, resolution|
        resize_image(
          path: img_url,
          width: resolution[:width],
          height: resolution[:height],
          output: File.join(["data", "images", post.slug, prefix, name]),
          quality: resolution[:quality],
          overwrite: overwrite
        )
      end
    end
  end

  def resize_image(
                   path : String,
                   width : Int32,
                   height : Int32,
                   output : String,
                   overwrite : Bool,
                   quality = 70)
    Dir.mkdir_p_dirname(output)

    magik_resize = "#{width}x#{height}"
    resized_quality_flag = "-quality #{quality}"
    command = "convert #{@flags} #{resized_quality_flag} -resize #{magik_resize} \"#{path}\" \"#{output}\""

    if overwrite || false == File.exists?(output)
      @logger.debug("ImageResizer: #{path} - #{width}x#{height}")
      `#{command}`
    end
  end

  def self.download_image(source : String, output : String)
    Dir.mkdir_p_dirname(output)
    command = "wget \"#{source}\" -O \"#{output}\" "
    `#{command}`
  end
end
