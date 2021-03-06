require "common_mark"

require "./std/markdown/parser" # hotfix for Crystal std lib

class Tremolite::MarkdownWrapper
  Log = ::Log.for(self)

  def initialize(@blog : Tremolite::Blog)
    # to process jekkyl-like functions
    @base_view = Tremolite::Views::BaseView.new(@blog).as(Tremolite::Views::BaseView)
  end

  def to_html(
    string : String,
    post : (Tremolite::Post | Nil) = nil
  ) : String
    # process functions
    string = @base_view.process_functions(string: string, post: post).as(String)
    html_from_md = crystal_cmark(string)
    return html_from_md
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
    return CommonMark.new(s, unsafe: true, normalize: true).to_html
  end

  # empty
  def null(s : String) : String
    return ""
  end
end
