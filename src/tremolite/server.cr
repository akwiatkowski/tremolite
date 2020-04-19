require "kemal"

class Tremolite::Server
  Log = ::Log.for(self)

  def initialize
    get "/" do
      File.read(File.join("public", "index.html"))
    end
  end

  def run
    Kemal.run
  end
end
