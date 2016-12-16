require "./base_view"

class Tremolite::Views::PaginatedListView < Tremolite::Views::BaseView
  PER_PAGE = 6

  def initialize(@blog : Tremolite::Blog, @posts : Array(Tremolite::Post), @page : Int32, @count : Int32)
  end

  def content
    data = Hash(String, String).new

    boxes = ""

    # posts
    @posts.each do |post|
      ph = Hash(String, String).new
      ph["klass"] = ""
      ph["post.url"] = post.url
      ph["post.small_image_url"] = post.small_image_url
      ph["post.title"] = post.title
      ph["post.date"] = post.date

      boxes += load_view("post/box", ph)
      boxes += "\n"
    end

    # prev
    if @page > 1
      data["prev_pagination"] = load_view("list/prev", {"prev_link" => self.class.url_for_page(@page - 1)})
    else
      data["prev_pagination"] = load_view("list/prev_blank")
    end

    # pagination
    ps = ""
    (1..@count).each do |i|
      if @page == i
        ps += load_view("list/pagination_current", {"page" => i.to_s})
      else
        ps += load_view("list/pagination_link", {"page" => i.to_s, "link" => self.class.url_for_page(i)})
      end
      ps += "\n"
    end
    data["pagination"] = ps

    # next
    if @page < (@count - 1)
      data["next_pagination"] = load_view("list/next", {"next_link" => self.class.url_for_page(@page + 1)})
    else
      data["next_pagination"] = load_view("list/next_blank")
    end

    data["postbox"] = boxes
    return load_view("list/index", data)
  end

  def self.url_for_page(page_number : Int32)
    url = "/list/page/#{page_number}"
    url = "/list/" if page_number == 1
    return url
  end
end
