# all views are hardcoded
require "./views/base_view"
require "./views/sitemap_generator"
require "./views/robot_generator"

class Tremolite::Renderer
  def initialize(@blog : Tremolite::Blog, @html_buffer : Tremolite::HtmlBuffer)
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

  # override this method in your code
  def render_all
  end

  # WARNING
  private def clear
    `rm -R public/*`
  end

  private def copy_assets
    `rsync -av data/assets/ public/`
  end

  private def copy_images
    `rsync -av data/images public/`
  end

  private def open_to_write_in_public(url : String) : File
    html_output_path = url_to_public_path(url)
    Dir.mkdir_p_dirname(html_output_path)
    f = File.open(html_output_path, "w")
    return f
  end

  private def write_output(view)
    write_output(url: view.url, content: view.output, view: view)
  end

  private def write_output(url : String, content : String, view = nil)
    # for checking conflicting paths
    @blog.not_nil!.validator.not_nil!.url_written(url)

    modified = @html_buffer.check(url: url, content: content, public_path: url_to_public_path(url))

    if modified
      f = open_to_write_in_public(url)
      f.puts(content)
      f.close
      @logger.info("Renderer: Wrote #{url.colorize(Colorize::COLOR_PATH)}")
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
