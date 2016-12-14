require "./post"

class Tremolite::Blog
  def initialize(
                 @posts_path = File.join("data", "posts"),
                 @posts_ext = "md")
    @posts = Array(Tremolite::Post).new
  end

  property :posts_path, :posts_ext

  def refresh
    initialize_posts
    refresh_posts
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
    end
  end

  def each_post_file(&block : String -> Nil)
    Dir[File.join([@posts_path, "*.#{@posts_ext}"])].each do |post_path|
      block.call(post_path)
    end
  end
end
