require "xml"

class Tremolite::Views::SiteMapGenerator
  def initialize(
                 @blog : Tremolite::Blog,
                 @url = "/sitemap.xml"
                 )
    @html_buffer = @blog.html_buffer.as(Tremolite::HtmlBuffer)
    @site_url = @blog.data_manager.not_nil!["site.url"].as(String)
  end

  getter :url

  def output
    to_xml
  end

  def to_xml
    content
  end

  def content
    s = header
    s += sitemap_content
    s += footer
    return s
  end

  def header
    return "<?xml version=\"1.0\" encoding=\"utf-8\"?>
    <urlset xmlns=\"http://www.sitemaps.org/schemas/sitemap/0.9\"
       xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"
       xsi:schemaLocation=\"http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd\">"
  end

  def footer
    return "</urlset>"
  end

  def sitemap_content
    s = ""
    @html_buffer.buffer.keys.each do |url|
      s += sitemap_url(url)
    end
    return s
  end

  def sitemap_url(url : String)
    s = "<url>\n"
    s += "<loc>#{@site_url}#{url}</loc>\n"
    s += "<lastmod>#{@html_buffer.crawler_lastmod[url].to_s("%Y-%m-%d")}</lastmod>\n" if @html_buffer.crawler_lastmod[url]?  # 2006-11-18
    #s += "<changefreq>#{@changefreq[url]}</changefreq>\n"
    #s += "<priority>#{@priority[url]}</priority>\n"
    s += "</url>\n"
    return s
  end
end
