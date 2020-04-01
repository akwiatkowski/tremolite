require "./post"

class Tremolite::PostCollection
  def initialize(
                 @blog : Tremolite::Blog,
                 @logger : Logger,
                 @posts_path : String,
                 @posts_ext : String)

    # when latest Post was updated
    # used in RSS/Atom
    @last_updated_at = Time.unix(0)
    @posts = Array(Tremolite::Post).new

    @logger.info("PostCollection: START")
  end

  getter :posts, :last_updated_at

  def initialize_posts
    @logger.info("#{self.class}: initialize_posts")
    @posts.clear
    
    each_post_file do |path|
      p = Tremolite::Post.new(blog: @blog.not_nil!, path: path)
      p.parse

      @logger.debug("PostCollection: Added #{p.slug}")

      if @last_updated_at.nil? || @last_updated_at.not_nil! < p.updated_at
        @last_updated_at = p.updated_at
      end

      # add only visible posts
      @posts << p if p.visible?
    end

    @posts = @posts.sort { |a, b| a.time <=> b.time }
  end

  def next_to(post : Tremolite::Post) : (Tremolite::Post | Nil)
    i = @posts.index(post)
    if i && i < (@posts.size - 1)
      return @posts[i + 1]
    else
      return nil
    end
  end

  def prev_to(post : Tremolite::Post) : (Tremolite::Post | Nil)
    i = @posts.index(post)
    if i && i > 0
      return @posts[i - 1]
    else
      return nil
    end
  end

  def each_post_file(&block : String -> Nil)
    Dir[File.join([@posts_path, "*.#{@posts_ext}"])].sort.each do |post_path|
      block.call(post_path)
    end
  end

  def posts_from_latest
    @posts.reverse
  end

  def each_post_from_latest(&block : Tremolite::Post -> Nil)
    posts_from_latest.each do |post|
      block.call(post)
    end
  end
end
