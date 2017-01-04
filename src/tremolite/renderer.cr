# all views are hardcoded
require "./views/base_view"

class Tremolite::Renderer
  def initialize(@blog : Tremolite::Blog)
    @logger = @blog.logger.as(Logger)
    @public_path = @blog.public_path.as(String)
    @data_path = @blog.public_path.as(String)
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

  # override this method in your code
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
    html_output_path = url_to_public_path(url)
    Dir.mkdir_p_dirname(html_output_path)
    f = File.open(html_output_path, "w")
    return f
  end

  private def check_if_modified(url : String, content : String)
    public_path = url_to_public_path(url)

    # if file not exists -> write
    return true if false == File.exists?(public_path)

    # TODO create buffer in RAM
    if File.read(public_path).strip.size == content.strip.size
      return false
    else
      return true
    end
  end

  private def write_output(url : String, content : String)
    modified = check_if_modified(url: url, content: content)

    if modified
      f = open_to_write_in_public(url)
      f.puts(content)
      f.close
      @logger.debug("Renderer: Wrote #{url.colorize(Colorize::COLOR_PATH)}")
    else
      # nothing
    end
  end

  private def prepare_path(p : String)
    Dir.mkdir_p(File.join([@public_path, p]))
  end

  private def url_to_public_path(url : String)
    op = File.join([@public_path, url])
    if File.extname(op) == ""
      op = File.join(op, "index.html")
    end
    return op
  end

  private def download_image_if_needed(local : String, remote : String)
    full_image_path = File.join(["data", local])
    if false == File.exists?(full_image_path)
      ImageResizer.download_image(source: remote, output: full_image_path)
    end
  end
end
