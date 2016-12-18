class Tremolite::Views::BaseView
  def initialize(@blog : Tremolite::Blog)
  end

  def to_html
    return top_html +
      head_open_html +
      tracking_html +
      head_close_html +
      open_body_html +
      nav_html +
      content +
      footer_html +
      close_body_html +
      close_html_html
  end

  def top_html
    # no parameters
    return load_html("include/top")
  end

  def head_open_html
    # no parameters
    return load_html("include/head_open")
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
    return File.read(p)
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
end
