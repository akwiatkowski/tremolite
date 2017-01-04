require "yaml"

class Tremolite::Post
  def initialize(@blog : Tremolite::Blog, @path : String)
    @content_string = String.new
    @header = YAML::Any.new(nil)

    @slug = (File.basename(@path)).gsub(/\..{1,10}$/, "").as(String)
    @title = String.new
    @subtitle = String.new
    @author = String.new
    @category = String.new
    @time = Time.epoch(0)

    @url = String.new
    @image_url = "/images/#{slug}/header.jpg"

    # to process jekkyl-like functions
    @base_view = Tremolite::Views::BaseView.new(@blog)

    custom_initialize
  end

  def custom_initialize
    # customize
  end

  getter :content_string, :header
  getter :url

  # from header or filename
  getter :title, :subtitle, :author, :slug, :time, :category
  getter :image_url

  def date
    @time.to_s("%Y-%m-%d")
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
    # for example `post_url`
    s = @base_view.process_functions(@content_string)
    # convert markdown to html
    ch = Tremolite::Utils::MarkdownWrapper.to_html(s)
    return ch
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
    @time = Time.parse(time: @header["date"].to_s, pattern: "%Y-%m-%d %H:%M:%S", kind: Time::Kind::Local)
  end

  def custom_process_header
    # customize
  end

  def process_paths
    @url = "/" + File.join([@category.to_s, @slug])
  end
end
