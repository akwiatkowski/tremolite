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

  def next_to(post : Tremolite::Post) : (Tremolite::Post | Nil)
    i = @posts.index(post)
    if i && i < (@posts.size - 1)
      return @posts[i+1]
    else
      return nil
    end
  end

  def prev_to(post : Tremolite::Post) : (Tremolite::Post | Nil)
    i = @posts.index(post)
    if i && i > 0
      return @posts[i-1]
    else
      return nil
    end
  end

  def each_post_file(&block : String -> Nil)
    Dir[File.join([@posts_path, "*.#{@posts_ext}"])].sort.each do |post_path|
      block.call(post_path)
    end
  end
end
