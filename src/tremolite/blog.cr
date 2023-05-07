require "log"
require "colorize"
require "./std/colorize" # used colors defined here
require "./std/float"
require "./std/string" # to_guid
require "./std/time"   # at_beginning_of_next_month

require "./posts/post_collection"
require "./renderer"
require "./image_resizer"
require "./data_manager"
require "./markdown_wrapper"
require "./html_buffer"
require "./validator"
require "./mod_watcher"

require "./uploader"

Log.setup_from_env

class Tremolite::Blog
  Log = ::Log.for(self)

  def initialize(
    @data_path = "data",
    @posts_ext = "md",
    @cache_path = "cache",
    @public_path = "public",
    @config_path = @data_path,
    @layout_path = File.join([@data_path, "layout"]).to_s,
    @assets_path = File.join([@data_path, "assets"]).to_s,
    @pages_path = File.join([@data_path, "pages"]).to_s,
    @mod_watcher_yaml_path : String? = nil
  )
    @posts_path = File.join([@data_path, "posts"])
    # end of semivariable configs

    Log.info { "START" }

    @html_buffer = Tremolite::HtmlBuffer.new
    @validator = Tremolite::Validator.new(blog: self)
    @renderer = Tremolite::Renderer.new(blog: self, html_buffer: @html_buffer.not_nil!)
    @image_resizer = Tremolite::ImageResizer.new(self)
    @data_manager = Tremolite::DataManager.new(
      self,
      config_path: @config_path.to_s
    )
    @markdown_wrapper = Tremolite::MarkdownWrapper.new(blog: self)
    @mod_watcher = Tremolite::ModWatcher.new(
      blog: self,
      file_path: @mod_watcher_yaml_path
    )

    @post_collection = Tremolite::PostCollection.new(
      blog: self,
      posts_path: @posts_path,
      posts_ext: @posts_ext
    )
  end

  def initialize_posts
    @post_collection.not_nil!.initialize_posts
  end

  # getters

  property :posts_path, :posts_ext
  getter :data_path, :public_path, :config_path, :cache_path,
    :layout_path, :assets_path, :pages_path
  getter :image_resizer, :html_buffer, :validator, :mod_watcher
  getter :server

  def data_manager
    return @data_manager.not_nil!
  end

  def post_collection
    return @post_collection.not_nil!
  end

  def markdown_wrapper
    return @markdown_wrapper.not_nil!
  end

  def renderer
    return @renderer.not_nil!
  end

  def validator
    return @validator.not_nil!
  end

  def mod_watcher
    return @mod_watcher.not_nil!
  end

  # end of getters

  # begin of core methods

  def render
    rendered.render
    validator.run
    mod_watcher.save_to_file
  end

  def run
    render
    run_server
  end

  def run_server
    @server.run
  end

  # the most important methods

  def url_to_public_path(url : String)
    op = File.join([@public_path, url])
    if File.extname(op) == ""
      op = File.join(op, "index.html")
    end
    return op
  end
end
