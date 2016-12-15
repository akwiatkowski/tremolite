# all layouts are hardcoded
require "./layouts/post_layout"
require "./layouts/home_layout"

class Tremolite::Renderer
  @@public_path = "public"

  def initialize(@blog : Tremolite::Blog)
    @logger = @blog.logger.as(Logger)
  end

  getter :blog

  def render
    process_images
    # clear # not needed every time
    copy_assets
    copy_images
    render_index
    render_posts
  end

  # resize to smaller images all assigned to post
  def process_images
    @logger.info("Renderer: Start image resize")

    blog.post_collection.posts.each do |post|
      blog.image_resizer.not_nil!.resize_all_images_for_post(post)
    end

    @logger.info("Renderer: End image resize")
  end

  # WARNING
  def clear
    `rm -R public/*`
  end

  def copy_assets
    `cp -R data/assets/* public/`
  end

  def copy_images
    `cp -nR data/images public/`
  end

  def render_index
    layout = Tremolite::Layouts::HomeLayout.new(blog: @blog)

    f = File.open(File.join("public", "index.html"), "w")
    f.puts layout.to_html
    f.close

    @logger.info("Renderer: Rendered INDEX")
  end

  def render_posts
    blog.post_collection.posts.each do |post|
      prepare_path(post.dir_path)
      render_post(post)

      @logger.info("Renderer: Rendered Post #{post.slug}")
    end
  end

  def render_post(post : Tremolite::Post)
    layout = Tremolite::Layouts::PostLayout.new(blog: @blog, post: post)

    f = File.new(File.join([@@public_path, post.output_path]), "w")
    f.puts layout.to_html
    f.close
  end

  def prepare_path(p : String)
    Dir.mkdir_p(File.join([@@public_path, p]))
  end
end
