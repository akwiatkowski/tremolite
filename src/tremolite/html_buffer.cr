require "crypto/md5"

class Tremolite::HtmlBuffer
  def initialize
    @buffer = Hash(String, String).new
  end

  getter :buffer

  # return true if file must be written
  def check(url : String, content : String, public_path : String) : Bool
    if @buffer[url]?.nil?
      # at this moment blog is generated every run so buffer is empty
      if File.exists?(public_path)
        # load existing file if exists
        @buffer[url] = File.read(public_path)
        # and compare
        result = compare_content(@buffer[url].strip, content.strip)

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

  def compare_content(a : String, b : String) : Bool
    return Crypto::MD5.hex_digest(a) != Crypto::MD5.hex_digest(b)
  end
end
