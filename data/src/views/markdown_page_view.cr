require "./page_view"

class MarkdownPageView < PageView
  def initialize(
    @blog : Tremolite::Blog,
    @file : String,
    @image_path : String,
    @title : String,
    @subtitle : String
    )

    @data_path = @blog.data_path.as(String)
    @path = File.join([@data_path, "src", "views", "pages", "#{file}.md"])
  end

  getter :image_path, :title, :subtitle

  def inner_html
    return Tremolite::Utils::MarkdownWrapper.to_html(File.read(@path))
  end
end
