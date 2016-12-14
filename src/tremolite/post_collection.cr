require "./post"

class Tremolite::PostCollection
  def initialize(@logger : Logger,
                 @posts_path : String,
                 @posts_ext : String)
    @posts = Array(Tremolite::Post).new

    @logger.info("PostCollection: START")

    initialize_posts
  end

  getter :posts

  private def initialize_posts
    each_post_file do |path|
      p = Tremolite::Post.new(path: path)
      p.parse

      @logger.info("PostCollection: Added #{p.slug}")

      @posts << p
    end
  end

  def each_post_file(&block : String -> Nil)
    Dir[File.join([@posts_path, "*.#{@posts_ext}"])].each do |post_path|
      block.call(post_path)
    end
  end
end
