require "logger"

require "./post_collection"
require "./renderer"

class Tremolite::Blog
  def initialize(
                 @logger = Logger.new(STDOUT),
                 @posts_path = File.join("data", "posts"),
                 @posts_ext = "md")


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
  end

  property :posts_path, :posts_ext
  getter :post_collection, :renderer
  getter :logger, :server

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
