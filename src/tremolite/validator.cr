class Tremolite::Validator
  Log = ::Log.for(self)

  def initialize(@blog : Tremolite::Blog)
    @html_buffer = @blog.not_nil!.html_buffer.as(Tremolite::HtmlBuffer)

    @paths = Array(String).new
  end

  getter :blog

  def url_written(url : String)
    @paths << url
  end

  def run
    Log.debug { "START" }

    check_conflicting_paths
    check_missing_title
    check_missing_referenced_links

    custom_validators

    # post checks
    clear_url_writes

    Log.debug { "DONE" }
  end

  # all custom written validators will be run within this method
  def custom_validators
  end

  def error_in_post(post : Tremolite::Post, error_string : String)
    Log.error { "Post #{post.slug}: #{error_string.to_s.colorize(:red)}" }
  end

  def warning_in_post(post : Tremolite::Post, error_string : String)
    Log.warn { "Post #{post.slug}: #{error_string.to_s.colorize(:yellow)}" }
  end

  def error_in_object(object, error_string : String)
    Log.error { "#{object.class}: #{error_string.to_s.colorize(:red)}" }
  end

  # here goes checks

  private def clear_url_writes
    @paths.clear
  end

  private def check_conflicting_paths
    a = @paths.uniq.size
    b = @paths.size
    if a != b
      Log.error { "path conflicts #{a} != #{b}" }
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
          Log.error { "missing title at #{url}" }
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
          Log.error { "missing referenced definitons at #{url}" }
          # removed sort because having order it's easier to find meaning of
          # link symbol, ex: when searcing for town in wikipedia
          result.map { |r| r[2] }.uniq.each do |r|
            # we want to use it most efficiently
            puts "[#{r.to_s.colorize(:red)}]: "
          end
        end
      end
    end
  end

  # no referenced links
  # missing background
end
