require "./page_view"

class MarkdownPageView < PageView
  def initialize(
                 @blog : Tremolite::Blog,
                 @url : String,
                 @file : String,
                 @image_path : String,
                 @title : String,
                 @subtitle : String)
    @data_path = @blog.data_path.as(String)
    @path = File.join([@data_path, "pages", "#{file}.md"])
  end

  getter :image_path, :title, :subtitle

  def inner_html
    return @blog.markdown_wrapper.to_html(File.read(@path))
  end
end
