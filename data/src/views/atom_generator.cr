require "xml"

class AtomGenerator
  def initialize(
    @blog : Tremolite::Blog,
    @posts : Array(Tremolite::Post),
    @site_title : String,
    @site_url : String,
    @site_desc : String,
    @url : String = "/feed_atom.xml",
    @site_guid : (String | Nil) = nil,
    @site_language : (String | Nil) = nil,
    @site_webmaster : (String | Nil) = nil,
    @author_name : (String | Nil) = nil,
    )
  end

  getter :url

  def to_xml
    content
  end

  def content
    s = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
    s += "<feed xmlns=\"http://www.w3.org/2005/Atom\">\n"
    s += atom_header
    s += atom_posts
    s += "</feed>"
    return s
  end

  def atom_header
    s = "<title>#{@site_title}</title>
    <link href=\"#{@site_url}\" />
    <updated>#{Time.now.to_s}</updated>
    <description>#{@site_desc}</description>
    "
    s += "<id>urn:uuid:#{@site_guid}</id>" unless @site_guid.nil?
    s += atom_header_author

    return s
  end

  def atom_header_author
    s = "<author>\n"
    s += "<name>#{@author_name}</name>\n" unless @author_name.nil?
    s += "<email>#{@site_webmaster}</email>\n" unless @site_webmaster.nil?
    s += "</author>\n"
    return s
  end

  def atom_posts
    s = ""
    @posts.each do |post|
      s += atom_post(post)
    end
    return s
  end

  def atom_post(post : Tremolite::Post)
    return "<entry>
             <title>#{post.title}</title>
             <link href=\"#{@site_url}#{post.url}\" />
             <updated>#{post.updated_at}</updated>
             <summary>#{post.subtitle}</summary>
             <id>urn:uuid:#{post.guuid}</id>
          </entry>"
  end

end
