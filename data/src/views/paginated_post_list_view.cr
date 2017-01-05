class PaginatedPostListView < BaseView
  PER_PAGE = 6

  def initialize(@blog : Tremolite::Blog, @posts : Array(Tremolite::Post), @page : Int32, @count : Int32)
  end

  def title
    "Lista wpisów #{@page}/#{@count}"
  end

  def content
    data = Hash(String, String).new

    boxes = ""

    # posts
    @posts.each do |post|
      ph = Hash(String, String).new
      ph["klass"] = ""
      ph["post.url"] = post.url
      ph["post.small_image_url"] = post.small_image_url.not_nil!
      ph["post.title"] = post.title
      ph["post.date"] = post.date

      boxes += load_html("post/box", ph)
      boxes += "\n"
    end

    # prev
    if @page > 1
      data["prev_pagination"] = load_html("list/prev", {"prev_link" => self.class.url_for_page(@page - 1)})
    else
      data["prev_pagination"] = load_html("list/prev_blank")
    end

    # pagination
    ps = ""
    (1..@count).each do |i|
      if @page == i
        ps += load_html("list/pagination_current", {"page" => i.to_s})
      else
        ps += load_html("list/pagination_link", {"page" => i.to_s, "link" => self.class.url_for_page(i)})
      end
      ps += "\n"
    end
    data["pagination"] = ps

    # next
    if @page < (@count - 1)
      data["next_pagination"] = load_html("list/next", {"next_link" => self.class.url_for_page(@page + 1)})
    else
      data["next_pagination"] = load_html("list/next_blank")
    end

    data["postbox"] = boxes
    return load_html("list/index", data)
  end

  def self.url_for_page(page_number : Int32)
    url = "/list/page/#{page_number}"
    url = "/list/" if page_number == 1
    return url
  end
end
