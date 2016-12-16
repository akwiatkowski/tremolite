# all views are hardcoded
require "./views/post_view"
require "./views/home_view"
require "./views/paginated_list_view"
require "./views/map_view"
require "./views/payload_json"

class Tremolite::Renderer
  @@public_path = "public"

  def initialize(@blog : Tremolite::Blog)
    @logger = @blog.logger.as(Logger)
  end

  getter :blog

  def render
    # clear # not needed every time
    copy_assets

    process_images(overwrite: false)
    copy_images

    render_index
    render_posts
    render_paginated_list
    render_map
    render_payload_json
  end

  # resize to smaller images all assigned to post
  def process_images(overwrite : Bool)
    @logger.info("Renderer: Start image resize")

    blog.post_collection.posts.each do |post|
      blog.image_resizer.not_nil!.resize_all_images_for_post(post: post, overwrite: overwrite)
    end

    @logger.info("Renderer: End image resize")
  end

  # WARNING
  def clear
    `rm -R public/*`
  end

  def copy_assets
    `cp -R data/assets/* public/`
  end

  def copy_images
    `cp -nR data/images public/`
  end

  def render_index
    view = Tremolite::Views::HomeView.new(blog: @blog)

    f = File.open(File.join("public", "index.html"), "w")
    f.puts view.to_html
    f.close

    @logger.info("Renderer: Rendered INDEX")
  end

  def render_paginated_list
    per_page = Tremolite::Views::PaginatedListView::PER_PAGE
    i = 0
    total_count = blog.post_collection.posts.size

    posts_per_pages = Array(Array(Tremolite::Post)).new

    while i < total_count
      from_idx = i
      to_idx = i + per_page - 1

      posts = blog.post_collection.posts_from_latest[from_idx..to_idx]
      posts_per_pages << posts

      i += per_page
    end

    posts_per_pages.each_with_index do |posts, i|
      page_number = i + 1
      url = "/list/page/#{page_number}"
      url = "/list/" if page_number == 1
      html_output_path = self.class.convert_url_to_local_path_with_public(url)

      # render and save
      view = Tremolite::Views::PaginatedListView.new(
        blog: @blog,
        posts: posts,
        page: page_number,
        count: posts_per_pages.size
      )

      Dir.mkdir_p_dirname(html_output_path)
      f = File.new(html_output_path, "w")
      f.puts view.to_html
      f.close

    end

    @logger.info("Renderer: Rendered paginated list")
  end

  def render_map
    view = Tremolite::Views::MapView.new(blog: @blog)

    url = "/map"
    html_output_path = self.class.convert_url_to_local_path_with_public(url)
    Dir.mkdir_p_dirname(html_output_path)
    f = File.open(html_output_path, "w")
    f.puts view.to_html
    f.close

    @logger.info("Renderer: Rendered map")
  end

  def render_payload_json
    view = Tremolite::Views::PayloadJson.new(blog: @blog)

    f = File.open(File.join("public", "payload.json"), "w")
    f.puts view.to_json
    f.close

    @logger.info("Renderer: Rendered payload.json")
  end

  def render_posts
    blog.post_collection.posts.each do |post|
      prepare_path(post.dir_path)
      render_post(post)

      @logger.info("Renderer: Rendered Post #{post.slug}")
    end
  end

  def render_post(post : Tremolite::Post)
    view = Tremolite::Views::PostView.new(blog: @blog, post: post)

    html_output_path = post.html_output_path
    Dir.mkdir_p_dirname(html_output_path)
    f = File.new(html_output_path, "w")
    f.puts view.to_html
    f.close
  end

  def prepare_path(p : String)
    Dir.mkdir_p(File.join([@@public_path, p]))
  end

  def self.convert_url_to_local_path_with_public(url : String)
    op = File.join([@@public_path, url])
    if File.extname(op) == ""
      op = File.join(op, "index.html")
    end
    return op
  end
end
