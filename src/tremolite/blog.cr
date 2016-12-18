require "logger"
require "colorize"
require "./std/colorize" # used colors defined here

require "./server"
require "./posts/post_collection"
require "./renderer"
require "./image_resizer"
require "./data_manager"

class Tremolite::Blog
  def initialize(
                 @logger = Logger.new(STDOUT),
                 @data_path = "data",
                 @posts_ext = "md",
                 @public_path = "public")
    @posts_path = File.join([@data_path, "posts"])
    # end of semivariable configs

    @logger.level = Logger::DEBUG
    # @logger.level = Logger::INFO
    @logger.formatter = Logger::Formatter.new do |severity, datetime, progname, message, io|
      io << severity[0] << ", [" << datetime.to_s("%H:%M:%S.%L") << "] "
      io << severity.rjust(5) << ": " << message
    end

    @logger.info("Tremolite: START")

    @server = Tremolite::Server.new(logger: @logger)

    @post_collection = Tremolite::PostCollection.new(
      logger: @logger,
      posts_path: @posts_path,
      posts_ext: @posts_ext
    )

    @renderer = Tremolite::Renderer.new(self)
    @image_resizer = Tremolite::ImageResizer.new(self)
    @data_manager = Tremolite::DataManager.new(self)
  end

  property :posts_path, :posts_ext
  getter :data_path, :public_path
  getter :post_collection, :renderer, :image_resizer, :data_manager
  getter :logger, :server

  # end of getters

  def run
    render
    run_server
  end

  def render
    @renderer.not_nil!.render
  end

  def run_server
    @server.run
  end
end
