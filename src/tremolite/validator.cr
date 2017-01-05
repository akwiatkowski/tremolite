class Tremolite::Validator
  def initialize(@blog : Tremolite::Blog)
    @logger = @blog.not_nil!.logger.as(Logger)
    @html_buffer = @blog.not_nil!.html_buffer.as(Tremolite::HtmlBuffer)

    @paths = Array(String).new
  end

  def url_written(url : String)
    @paths << url
  end

  def run
    @logger.debug("Validator: start")

    check_conflicting_paths
    check_missing_title

    # post checks
    clear_url_writes

    @logger.debug("Validator: end")
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

  private def check_missing_title
    @html_buffer.buffer.each do |url, content|
      result = content.scan(/<title>([^<]+)<\/title>/)
      if result.size != 1
        @logger.error("Validator: missing title at #{url}")
      end
    end
  end

  # missing title
  # no referenced links
  # missing background
end
