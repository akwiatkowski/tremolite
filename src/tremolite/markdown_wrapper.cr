require "markdown"
require "common_mark"

require "./std/markdown/parser" # hotfix for Crystal std lib

class Tremolite::MarkdownWrapper
  def initialize(@blog : Tremolite::Blog)
    # to process jekkyl-like functions
    @base_view = Tremolite::Views::BaseView.new(@blog).as(Tremolite::Views::BaseView)
  end

  def to_html(s : String) : String
    # process functions
    s = @base_view.process_functions(s).as(String)
    return crystal_cmark(s)
  end

  # use external command
  def command(s : String) : String
  end

  # use STD
  def crystal(s : String) : String
    return Markdown.to_html(s)
  end

  # use lib
  def crystal_cmark(s : String) : String
    return CommonMark.new(s).to_html
  end

  # empty
  def null(s : String) : String
    return ""
  end
end