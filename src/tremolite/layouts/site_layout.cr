class Tremolite::Layouts::SiteLayout
  def initialize(@blog : Tremolite::Blog)
  end

  def to_html
    return top_html +
      head_html +
      open_body +
      nav_html +
      content +
      footer_html +
      close_body +
      close_html
  end


  def top_html
    return load_layout("top")
  end

  def head_html
    return load_layout("head")
  end

  def open_body
    "<body>\n"
  end

  def close_body
    "</body>\n"
  end

  def close_html
    "</html>\n"
  end

  def nav_html
    return load_layout("nav")
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
