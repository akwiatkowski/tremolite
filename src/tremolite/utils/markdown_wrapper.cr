require "markdown"
require "common_mark"

require "../std/markdown/parser" # hotfix for Crystal std lib

class Tremolite::Utils::MarkdownWrapper
  def self.to_html(s : String) : String
    return crystal_cmark(s)
  end

  def self.command(s : String) : String
  end

  def self.crystal(s : String) : String
    return Markdown.to_html(s)
  end

  def self.crystal_cmark(s : String) : String
    return CommonMark.new(s).to_html
  end

  def self.null(s : String) : String
    return ""
  end
end
