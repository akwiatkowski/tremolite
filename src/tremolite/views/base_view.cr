require "./abstract_view"

class Tremolite::Views::BaseView < Tremolite::Views::AbstractView
  def initialize(@blog : Tremolite::Blog, @url = "")
  end

  # this should be much faster if `data` has more keys than document has fields
  def load_html(name : String, data : Hash(String, String))
    s = load_html(name)
    result = s.scan(Regex.new("{{\\s*(\\S+)\\s*}}"))
    result.each do |r|
      if data[r[1].to_s]?
        s = s.gsub(r[0], data[r[1]])
      end
    end

    return s
  end

  def load_html(name : String)
    p = File.join(self.data_path, "layout", "#{name}.html")
    s = File.read(p)
    s = process_functions(s)
    return s
  end

  def process_functions(
      string : String,
      post : (Tremolite::Post | Nil) = nil
    )
    # predefined functions
    result = string.scan(/\{%\s*(\S+)\s+(\S+)\s*%\}/)
    result.each do |r|
      if r[1].to_s == "post_url"
        find_posts = @blog.post_collection.posts.select { |p| p.slug == r[2] }
        if find_posts.size > 0
          string = string.gsub(r[0], find_posts[0].url)
        else
          @blog.logger.error("Not found post_url for #{r[2]}")
          # TODO add place to report errors
        end
        next
      end
    end

    # customizable functions
    result = string.scan(/\{%\s*([^%]+)\s*%\}/)
    result.each do |r|
      result = custom_process_function(command: r[1].to_s, string: string, post: post)
      # if parser found functionm it will overwrite (with `{% %}`)
      if result
        string = string.gsub(r[0], result.as(String))
      end
    end

    return string
  end

  #
  # command - string withing `{% the string %}`
  # string - post string, probably now is not used
  # post - if run within post
  def custom_process_function(
      command : String,
      string : String,
      post : (Tremolite::Post | Nil)
    ) : (String | Nil)

    return nil
  end

  def process_variable(string : String, key : String, value : String)
    self.class.process_variable(string, key, value)
  end

  def self.process_variable(string : String, key : String, value : String)
    escaped_key = key.gsub(/\./, "\.")
    regexp = Regex.new("{{\\s*#{escaped_key}\\s*}}")
    return string.gsub(regexp, value)
  end

  protected def data_path
    @blog.data_path.as(String)
  end

  # Try to allow one method create result by
  # joining various parts of html
  def to_html
    return top_html +
      head_open_html +
      title_html +
      tracking_html +
      head_close_html +
      open_body_html +
      nav_html +
      content +
      footer_html +
      close_body_html +
      close_html_html
  end

  # Alias to refactor `write_output`
  def output
    to_html
  end

  # Load html partials
  def top_html
    # no parameters
    return load_html("include/top")
  end

  def head_open_html
    # no parameters
    return load_html("include/head_open")
  end

  def title_html
    return "<title>#{title}</title>\n"
  end

  def title
    return ""
  end

  def tracking_html
    # no parameters
    return load_html("include/tracking")
  end

  def head_close_html
    "</head>\n"
  end

  def open_body_html
    "<body>\n"
  end

  def close_body_html
    "</body>\n"
  end

  def close_html_html
    "</html>\n"
  end

  # Some partials are parametrized
  def nav_html
    # parametrized
    h = Hash(String, String).new
    h["site.title"] = @blog.data_manager.not_nil!["site.title"] if @blog.data_manager.not_nil!["site.title"]?

    return load_html("include/nav", h)
  end

  def content
    return ""
  end

  def footer_html
    h = Hash(String, String).new
    h["site.title"] = @blog.data_manager.not_nil!["site.title"] if @blog.data_manager.not_nil!["site.title"]?
    h["year"] = Time.now.year.to_s

    return load_html("include/footer", h)
  end
end
