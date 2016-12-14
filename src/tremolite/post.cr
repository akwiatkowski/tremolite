require "markdown"
require "./std/markdown/parser"

require "yaml"

class Tremolite::Post
  @@public_path = "public"

  def initialize(@path : String)
    @content_string = String.new
    @content_html = String.new
    @header = YAML::Any.new(nil)

    @slug = (File.basename(@path)).gsub(/\..{1,10}$/, "").as(String)
    @title = String.new

    @output_path = String.new
    @dir_path = String.new
  end

  getter :content_string, :content_html, :header
  getter :output_path, :dir_path
  # from header
  getter :title

  def parse
    s = File.read(@path)

    header_idxs = Array(Int32).new

    s.lines.each_with_index do |line, i|
      if line =~ /\-{3,100}/
        header_idxs << i
      end
    end

    if header_idxs.size >= 2
      header_string = s.lines[(header_idxs[0] + 1)...(header_idxs[1])].join("")
      @header = YAML.parse(header_string)

      @content_string = s.lines[(header_idxs[1] + 1)..(-1)].join("")
      @content_html = Markdown.to_html(@content_string)

      @title = @header["title"].to_s
    else
      return nil
    end
  end

  def process_paths
    @output_path = File.join([@header["categories"].to_s, @slug])
    if File.extname(@output_path) == ""
      @output_path = File.join(@output_path, "index.html")
    end

    @dir_path = File.dirname(output_path)
  end

  def render_paths
    Dir.mkdir_p(File.join([@@public_path, @dir_path]))
  end

  def render_output
    f = File.new(File.join([@@public_path, @output_path]), "w")
    f.puts full_output_html
    f.close
  end

  def full_output_html
    @content_html
  end

  def render
    process_paths
    render_paths
    render_output
  end

end
