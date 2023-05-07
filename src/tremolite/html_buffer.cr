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

    # referenced link buffer
    @referenced_links = Hash(String, NamedTuple(url: String, post_slug: String?)).new
  end

  getter :buffer, :add_to_sitemap, :post_last_modified
  # for sitemap
  getter :crawler_changefreq, :crawler_lastmod

  def store_referenced_link(
    key : String,
    url : String,
    optional : String = "",
    post_slug : String = ""
  )
    if @referenced_links[key]?.nil?
      @referenced_links[key] = {url: url, post_slug: post_slug}
    end
  end

  def get_referenced_link(key : String)
    return @referenced_links[key]?
  end

  def referenced_links_count
    return @referenced_links.size
  end

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
        result = compare_content(
          old_content: @buffer[url].strip,
          new_content: content.strip
        )

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

        # show diff of what was changed
        if result
          display_diff_of_content(
            url: url,
            old_content: @buffer[url],
            new_content: content
          )
        end

        # overwrite buffer
        @buffer[url] = content

        # return if it differs
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

  def compare_content(old_content : String, new_content : String) : Bool
    return Digest::MD5.hexdigest(old_content) != Digest::MD5.hexdigest(new_content)
  end

  def display_diff_of_content(url : String, old_content : String, new_content : String)
    old_array = old_content.split("\n")
    new_array = new_content.split("\n")

    if old_array.size != new_array.size
      # hard to compare easily
      puts "old lines #{old_array.size} != new lines #{new_array.size}"
    else
      # compare line by line
      (0...old_array.size).each do |i|
        if old_array[i] != new_array[i]
          diff_lines(url, i, old_array[i], new_array[i])
        end
      end
    end
  end

  def diff_lines(url, i, old_line, new_line)
    # line_max_size = [old_line.size, new_line.size].max
    #
    # result = String.build do |s|
    #   (0...line_max_size).each do |j|
    #     if
    #   end
    # end

    puts "#{url} @ #{i} was changed"
    puts "- #{old_line}"
    puts "+ #{new_line}"
  end
end
