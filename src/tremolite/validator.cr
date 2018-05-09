class Tremolite::Validator
  def initialize(@blog : Tremolite::Blog)
    @logger = @blog.not_nil!.logger.as(Logger)
    @html_buffer = @blog.not_nil!.html_buffer.as(Tremolite::HtmlBuffer)

    @paths = Array(String).new
  end

  getter :blog

  def url_written(url : String)
    @paths << url
  end

  def run
    @logger.debug("Validator: start")

    check_conflicting_paths
    check_missing_title
    check_missing_referenced_links

    # post checks
    clear_url_writes

    @logger.debug("Validator: end")
  end

  def error_in_post(post : Tremolite::Post, error_string : String)
    @logger.error("Post #{post.slug}: #{error_string.to_s.colorize(:red)}")
  end

  def error_in_object(object, error_string : String)
    @logger.error("#{object.class}: #{error_string.to_s.colorize(:red)}")
  end

  # here goes checks

  private def clear_url_writes
    @paths.clear
  end

  private def check_conflicting_paths
    a = @paths.uniq.size
    b = @paths.size
    if a != b
      @logger.error("Validator: path conflicts #{a} != #{b}")
    end
  end

  private def is_url_html?(url)
    File.extname(url).to_s == ""
  end

  private def check_missing_title
    @html_buffer.buffer.each do |url, content|
      if is_url_html?(url)
        # only check html
        result = content.scan(/<title>([^<]+)<\/title>/)
        if result.size != 1
          @logger.error("Validator: missing title at #{url}")
        end
      end
    end
  end

  private def check_missing_referenced_links
    @html_buffer.buffer.each do |url, content|
      if is_url_html?(url)
        # only check html
        result = content.scan(/\[([^]]+)\]\[([^]]+)\]/)
        if result.size > 0
          @logger.error("Validator: missing referenced definitons at #{url}")
          result.each do |r|
            @logger.error("Validator: missing [#{r[2].to_s.colorize(:red)}]")
          end
        end
      end
    end
  end

  # no referenced links
  # missing background
end
