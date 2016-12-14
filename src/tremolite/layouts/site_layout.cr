class Tremolite::Layouts::SiteLayout
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
    return load_layout("top")
  end

  def head_open_html
    return load_layout("head_open")
  end

  def tracking_html
    return load_layout("tracking")
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
    h = Hash(String, String).new
    h["site.title"] = @blog.vs["site.title"] if @blog.vs["site.title"]?

    return load_layout("nav", h)
  end

  def content
    # TODO
    ""
  end

  def footer_html
    return load_layout("footer")
  end

  def load_layout(name : String, data : Hash(String, String))
    s = load_layout(name)

    data.each do |key, value|
      s = self.process_variable(s, key, value)
    end

    return s
  end

  def load_layout(name : String)
    self.class.load_layout(name)
  end

  def process_variable(string : String, key : String, value : String)
    self.class.process_variable(string, key, value)
  end

  def self.load_layout(name : String)
    p = File.join("data", "layout", "#{name}.html")
    return File.read(p)
  end

  def self.process_variable(string : String, key : String, value : String)
    escaped_key = key.gsub(/\./, "\.")
    regexp = Regex.new("{{\\s*#{escaped_key}\\s*}}")
    return string.gsub(regexp, value)
  end
end