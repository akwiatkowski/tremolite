class Dir
  def self.mkdir_p_dirname(p : String)
    Dir.mkdir_p(File.dirname(p))
  end
end
