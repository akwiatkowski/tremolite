require "./abstract_view"

require "xml"

class Tremolite::Views::RobotGenerator < Tremolite::Views::AbstractView
  Log = ::Log.for(self)

  def initialize(
    @url = "/robots.txt"
  )
  end

  getter :url

  def output
    to_txt
  end

  def to_txt
    content
  end

  def content
    return "User-agent: *\nDisallow:\n"
  end
end
