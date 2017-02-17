require "logger"
require "colorize"
require "./std/colorize" # used colors defined here
require "./std/float"
require "./std/string" # to_guid

require "./server"
require "./posts/post_collection"
require "./renderer"
require "./image_resizer"
require "./data_manager"
require "./markdown_wrapper"
require "./html_buffer"
require "./validator"

require "./uploader"

class Tremolite::Blog
  def initialize(
                 @logger = Logger.new(STDOUT),
                 @data_path = "data",
                 @posts_ext = "md",
                 @public_path = "public")
    @posts_path = File.join([@data_path, "posts"])
    # end of semivariable configs

    @logger.formatter = Logger::Formatter.new do |severity, datetime, progname, message, io|
      color = :white
      color = :yellow if severity == "WARN"
      color = :red if severity == "ERROR"

      io << severity[0] << ", [" << datetime.to_s("%H:%M:%S.%L") << "] "
      io << severity.rjust(5).colorize(color) << ": " << message
    end

    @logger.info("Tremolite: START")

    @server = Tremolite::Server.new(logger: @logger)

    @post_collection = Tremolite::PostCollection.new(
      blog: self,
      logger: @logger,
      posts_path: @posts_path,
      posts_ext: @posts_ext
    )

    @html_buffer = Tremolite::HtmlBuffer.new
    @validator = Tremolite::Validator.new(blog: self)
    @renderer = Tremolite::Renderer.new(blog: self, html_buffer: @html_buffer.not_nil!)
    @image_resizer = Tremolite::ImageResizer.new(self)
    @data_manager = Tremolite::DataManager.new(self)
    @markdown_wrapper = Tremolite::MarkdownWrapper.new(blog: self)
  end

  property :posts_path, :posts_ext
  getter :data_path, :public_path
  getter :renderer, :image_resizer, :data_manager, :html_buffer, :validator
  getter :logger, :server

  def post_collection
    return @post_collection.not_nil!
  end

  def markdown_wrapper
    return @markdown_wrapper.not_nil!
  end

  # end of getters

  def run
    render
    run_server
  end

  def render
    @renderer.not_nil!.render
    @validator.not_nil!.run
  end

  def run_server
    @server.run
  end
end
