class Tremolite::ModWatcher
  Log = ::Log.for(self)

  alias ModHash = Hash(String, String | Hash(String, String))

  getter :enabled

  def initialize(
    @blog : Tremolite::Blog,
    file_path : String?
  )
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

    Log.debug { "@enabled = #{@enabled}" }
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

  # override this method in your code
  def update_before_save
  end

  def save_to_file
    return unless @enabled
    Log.debug { "save_to_file START" }

    update_before_save
    Log.debug { "update_before_save DONE" }

    File.open(@file_path, "w") do |f|
      @data.to_yaml(f)
    end

    Log.debug { "save_to_file DONE" }
  end

  def load_from_file
    return unless @enabled

    if File.exists?(@file_path)
      @data = Hash(String, ModHash).from_yaml(File.open(@file_path))
    end
  end
end
