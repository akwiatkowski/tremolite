require "digest/md5"

class Tremolite::HtmlBuffer
  Log = ::Log.for(self)

  def initialize
    @buffer = Hash(String, String).new
    @should_add_to_sitemap = Hash(String, Bool).new
    @post_last_modified = Time::UNIX_EPOCH.as(Time)

    # for sitemap
    @crawler_changefreq = Hash(String, String).new
    @crawler_lastmod = Hash(String, Time).new
  end

  getter :buffer, :add_to_sitemap, :post_last_modified
  # for sitemap
  getter :crawler_changefreq, :crawler_lastmod

  # return true if file must be written
  def check(url : String, content : String, public_path : String, add_to_sitemap : Bool = true, view = nil) : Bool
    if @buffer[url]?.nil?
      # at this moment blog is generated every run so buffer is empty
      if File.exists?(public_path)
        # load existing file if exists
        @buffer[url] = File.read(public_path)
        # set last modification time
        @crawler_lastmod[url] = File.info(public_path).modification_time
        # and compare
        result = compare_content(@buffer[url].strip, content.strip)

        if view
          # `changefreq` for SITEMAP.XML
          if view.not_nil!.responds_to?(:crawler_changefreq)
            @crawler_changefreq[url] = view.not_nil!.crawler_changefreq
          end

          # will be added if `add_to_sitemap` is true and view `#add_to_sitemap`
          # is also true
          if add_to_sitemap && view.add_to_sitemap
            @should_add_to_sitemap[url] = true
          end
        else
          # if view is missing it will be only added if `add_to_sitemap` is true
          if add_to_sitemap
            @should_add_to_sitemap[url] = true
          end
        end

        # overwrite buffer
        @buffer[url] = content

        # return result
        return result
      else
        # if not - set
        @buffer[url] = content
        # and return true
        return true
      end
    else
      # in future blog instance could be refreshed for all not `*.cr` files
      result = (@buffer[url] != content)
      # overwrite buffer
      @buffer[url] = content
      # return result
      return result
    end
  end

  def add_to_sitemap_urls : Array(String)
    return @should_add_to_sitemap.keys
  end

  def compare_content(a : String, b : String) : Bool
    return Digest::MD5.hexdigest(a) != Digest::MD5.hexdigest(b)
  end
end
