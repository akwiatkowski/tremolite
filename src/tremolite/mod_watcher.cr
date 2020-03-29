class Tremolite::ModWatcher
  alias ModHash = Hash(String, String)

  def initialize(
    @blog : Tremolite::Blog,
    file_path : String?
  )
    @logger = @blog.logger.as(Logger)
    # by default it's disabled
    @enabled = false
    # default empty data container
    @data = Hash(String, ModHash).new

    if file_path
      # let's enable this only when you provide yaml file path
      @enabled = true
      @file_path = file_path.not_nil!.as(String)
      load_from_file
    else
      # internally set this as empty string
      @file_path = ""
    end

    @logger.debug("#{self.class} @enabled=#{@enabled}")
    @logger.debug("#{self.class} @data=#{@data.inspect}")
  end

  def get(key : String)
    # initialize with empty when missing
    unless @data[key]?
      @data[key] = ModHash.new
    end

    return @data[key]?
  end

  def set(key : String, data : ModHash)
    @data[key] = data
  end

  def compare(key : String, compare_data : ModHash)
    stored_data = get(key)
    result = (stored_data != compare_data)

    @logger.debug("#{self.class}: compare stored_data=#{stored_data} != compare_data=#{compare_data} => #{result}")

    return result
  end

  # when you override `#current_for` you can compare
  # mod. data using only this method
  def compare(key : String)
    compare(
      key: key,
      compare_data: current_for(key)
    )
  end

  def update_only_when_changed(key, &block)
    if compare(key)
      # block can take a lot of time and update mod. data
      # for example change exif data
      block.call
      # update mod. data after
      set(key, current_for(key))
    end
  end

  # overwrite this
  def current_for(key : String) : ModHash
    return ModHash.new
  end

  def save_to_file
    return unless @enabled
    @logger.debug("#{self.class}: save_to_file")

    File.open(@file_path, "w") do |f|
      @data.to_yaml(f)
    end
  end

  def load_from_file
    return unless @enabled

    if File.exists?(@file_path)
      @data = Hash(String, ModHash).from_yaml(File.open(@file_path))
    end
  end
end
