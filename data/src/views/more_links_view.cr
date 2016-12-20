class MoreLinksView < BaseView
  def initialize(@blog : Tremolite::Blog)
  end

  def inner_html
    "TEST"
  end
end
