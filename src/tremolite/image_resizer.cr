class Tremolite::ImageResizer
  Log = ::Log.for(self)

  @@sizez = {
    "small" => {width: 600, height: 400, quality: 65},
    "thumb" => {width: 60, height: 40, quality: 70},
  }
  @@quality = 70

  PROCESSED_IMAGES_PATH         = File.join(["images", "processed"])
  PROCESSED_IMAGES_PATH_FOR_WEB = File.join(["/", "images", "processed"])

  def initialize(@blog : Tremolite::Blog)
    @data_path = @blog.data_path.as(String)
    @public_path = @blog.public_path.as(String)
    @processed_path = File.join([@public_path, PROCESSED_IMAGES_PATH])
    @flags = "-interlace Plane"
    # -strip - removed strip because it messed with color space, exif is ok
  end

  def resize_all_images_for_post(post : Tremolite::Post, overwrite : Bool)
    # iterate by all images in proper direcory
    path = File.join([@data_path, post.images_dir_url])
    Dir.mkdir_p(path) # unless File.exists?(path)
    Dir.entries(path).each do |name|
      if false == File.directory?(File.join([path, name]))
        resize_for_post(post: post, name: name, overwrite: overwrite)
      end
    end
  end

  # Use this method for all processed images paths
  def self.processed_path_for_post(
    processed_path : String,
    post_year : Int32,
    post_month : Int32,
    post_slug : String,
    prefix : String,
    file_name : String
  ) : String
    post_month_string = post_month < 10 ? "0#{post_month}" : post_month.to_s
    file_name_wo_jpg = file_name.gsub(/\.jpg/i, "")

    return File.join([processed_path, post_year.to_s, post_month_string, "#{post_slug}_#{file_name_wo_jpg}_#{prefix}.jpg"])
  end

  def resize_for_post(post : Tremolite::Post, overwrite : Bool, name = "header.jpg")
    img_url = File.join([@data_path, "images", post.year.to_s, post.slug, name])
    if File.exists?(img_url)
      # there are defined sizes of output images
      @@sizez.each do |prefix, resolution|
        # output_url = File.join([@processed_path, "#{post.year}", "#{post.slug}_#{prefix}_#{name}"])
        output_url = self.class.processed_path_for_post(
          processed_path: @processed_path,
          post_year: post.year,
          post_month: post.time.month,
          post_slug: post.slug,
          prefix: prefix,
          file_name: name
        )

        resize_image(
          path: img_url,
          width: resolution[:width],
          height: resolution[:height],
          output: output_url,
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
    quality = 70
  )
    Dir.mkdir_p_dirname(output)

    magik_resize = "#{width}x#{height}"
    resized_quality_flag = "-quality #{quality}"
    command = "convert #{@flags} #{resized_quality_flag} -resize #{magik_resize} \"#{path}\" \"#{output}\""

    if overwrite || false == File.exists?(output)
      Log.info { "#{path} - #{width}x#{height}" }
      `#{command}`
    end
  end

  # deprecated
  def self.download_image(source : String, output : String)
    Dir.mkdir_p_dirname(output)
    command = "wget \"#{source}\" -O \"#{output}\" "
    `#{command}`
  end

  def self.copy_image(source : String, output : String)
    Dir.mkdir_p_dirname(output)
    command = "cp \"#{source}\" \"#{output}\" "
    `#{command}`
  end
end
