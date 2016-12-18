# all views are hardcoded
require "./views/post_view"
require "./views/tag_view"
require "./views/land_view"
require "./views/town_view"
require "./views/more_view"

class Tremolite::Renderer
  def initialize(@blog : Tremolite::Blog)
    @logger = @blog.logger.as(Logger)
    @public_path = @blog.public_path.as(String)
  end

  getter :blog

  def render
    # clear # not needed every time
    copy_assets

    process_images(overwrite: false)
    copy_images

    render_all
  end

  # Resize all post images to small, thumb, ...
  private def process_images(overwrite : Bool)
    @logger.info("Renderer: Start image resize")

    blog.post_collection.posts.each do |post|
      blog.image_resizer.not_nil!.resize_all_images_for_post(post: post, overwrite: overwrite)
    end

    @logger.info("Renderer: End image resize")
  end

  # override this method
  def render_all
  end

  # WARNING
  private def clear
    `rm -R public/*`
  end

  private def copy_assets
    `cp -R data/assets/* public/`
  end

  private def copy_images
    `cp -nR data/images public/`
  end

  private def open_to_write_in_public(url : String) : File
    html_output_path = convert_url_to_local_path_with_public(url)
    Dir.mkdir_p_dirname(html_output_path)
    f = File.open(html_output_path, "w")
    return f
  end

  private def write_output(url : String, content : String)
    f = open_to_write_in_public(url)
    f.puts(content)
    f.close

    @logger.debug("Renderer: Wrote #{url.colorize(Colorize::COLOR_PATH)}")
  end

  private def prepare_path(p : String)
    Dir.mkdir_p(File.join([@public_path, p]))
  end

  private def convert_url_to_local_path_with_public(url : String)
    op = File.join([@public_path, url])
    if File.extname(op) == ""
      op = File.join(op, "index.html")
    end
    return op
  end
end
