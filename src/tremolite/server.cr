require "kemal"

class Tremolite::Server
  def initialize(@logger : Logger)
    get "/" do
      File.read(File.join("public", "index.html"))
    end
  end

  def run
    Kemal.run
  end
end
