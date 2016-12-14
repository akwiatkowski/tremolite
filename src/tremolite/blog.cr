require "./post"

class Tremolite::Blog
  def initialize(
                 @posts_path = File.join("data", "posts"),
                 @posts_ext = "md")
    @posts = Array(Tremolite::Post).new
    @server = Tremolite::Server.new
  end

  property :posts_path, :posts_ext
  getter :server

  def refresh
    initialize_posts
    refresh_posts
    generate_links
  end

  def run_server
    @server.run
  end

  def initialize_posts
    each_post_file do |path|
      p = Tremolite::Post.new(path: path)
      @posts << p
    end
  end

  def refresh_posts
    @posts.each do |post|
      post.parse
      post.render
    end
  end

  def generate_links
    f = File.open(File.join("public", "index.html"), "w")
    @posts.each do |post|
      f.puts "<a href=\"#{post.output_path}\">#{post.title}</a><br\>"
    end
    f.close
  end

  def each_post_file(&block : String -> Nil)
    Dir[File.join([@posts_path, "*.#{@posts_ext}"])].each do |post_path|
      block.call(post_path)
    end
  end
end
