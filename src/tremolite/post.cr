require "markdown"
require "./std/markdown/parser"

require "yaml"

class Tremolite::Post
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
  # from header or filename
  getter :title, :slug

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

      # is valid, process rest
      process
    else
      return nil
    end
  end

  private def process
    process_header
    process_paths
  end

  private def process_header
    @title = @header["title"].to_s
  end

  private def process_paths
    @output_path = File.join([@header["categories"].to_s, @slug])
    if File.extname(@output_path) == ""
      @output_path = File.join(@output_path, "index.html")
    end

    @dir_path = File.dirname(output_path)
  end
end
