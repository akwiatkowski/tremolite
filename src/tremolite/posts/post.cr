require "yaml"
require "digest/md5"

class Tremolite::Post
  def initialize(@blog : Tremolite::Blog, @path : String)
    @logger = @blog.logger.as(Logger)

    @content_string = String.new
    @header = YAML::Any.new(nil)

    @slug = (File.basename(@path)).gsub(/\..{1,10}$/, "").as(String)
    @title = String.new
    @subtitle = String.new
    @author = String.new
    @category = String.new
    @time = Time.epoch(0)

    @url = String.new

    custom_initialize
  end

  def custom_initialize
    # customize
  end

  getter :content_string, :header
  getter :url

  # from header or filename
  getter :title, :subtitle, :author, :slug, :time, :category

  def images_dir_url
    "/images/#{self.year}/#{slug}/"
  end

  def image_url
    images_dir_url + "header.jpg"
  end

  def public_image_url
    @blog.url_to_public_path(image_url)
  end

  def date
    @time.to_s("%Y-%m-%d")
  end

  def year
    @time.year
  end

  def updated_at
    File.info(@path).modification_time
  end

  # for atom feed
  def guuid
    return Digest::MD5.hexdigest(self.slug).to_guid
  end

  # end of header getters

  LINE_JOIN_STRING = "\n"

  def parse
    s = File.read(@path)

    header_idxs = Array(Int32).new

    s.lines.each_with_index do |line, i|
      if line =~ /\-{3,100}/
        header_idxs << i
      end
    end

    if header_idxs.size >= 2
      header_string = s.lines[(header_idxs[0] + 1)...(header_idxs[1])].join(LINE_JOIN_STRING) # \n, before was ""
      @header = YAML.parse(header_string)

      @content_string = s.lines[(header_idxs[1] + 1)..(-1)].join(LINE_JOIN_STRING)

      # is valid, process rest
      process
    else
      return nil
    end
  end

  # to allow using jekkyl-like post_url functions
  # we need to process to html after initial post processing
  def content_html
    return @blog.markdown_wrapper.to_html(string: @content_string, post: self)
  end

  def process
    process_header
    process_paths

    custom_process_header
  end

  def process_header
    @title = @header["title"].to_s
    @subtitle = @header["subtitle"].to_s
    @author = @header["author"].to_s
    @category = @header["categories"].to_s
    @time = Time.parse(
      time: @header["date"].to_s,
      pattern: "%Y-%m-%d %H:%M:%S",
      location: Time::Location.load_local
     )
  end

  def custom_process_header
    # customize
  end

  def process_paths
    @url = "/" + File.join([@category.to_s, @slug])
  end

  # by default all posts are visible, can be overriden
  def visible?
    true
  end
end
