require "./page_view"

class Tremolite::Views::MoreView < Tremolite::Views::PageView
  def initialize(@blog : Tremolite::Blog)
  end

  def inner_html
    "TEST"
  end
end
