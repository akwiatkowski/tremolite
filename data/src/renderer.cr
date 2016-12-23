require "./views/base_view"
require "./views/page_view"

require "./views/home_view"
require "./views/paginated_post_list_view"
require "./views/map_view"
require "./views/payload_json_generator"
require "./views/tag_view"
require "./views/town_view"
require "./views/land_view"
require "./views/post_view"
require "./views/markdown_page_view"

class Tremolite::Renderer
  def render_all
    render_index
    render_posts
    render_paginated_list
    render_map
    render_payload_json
    render_tags_pages
    render_lands_pages
    render_towns_pages

    render_more_page
    render_about_page
  end

  def render_index
    view = HomeView.new(blog: @blog)
    write_output("/", view.to_html)
  end

  def render_paginated_list
    per_page = PaginatedPostListView::PER_PAGE
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

      # render and save
      view = PaginatedPostListView.new(
        blog: @blog,
        posts: posts,
        page: page_number,
        count: posts_per_pages.size
      )

      write_output(url, view.to_html)
    end

    @logger.info("Renderer: Rendered paginated list")
  end

  def render_map
    view = MapView.new(blog: @blog)
    url = "/map"
    write_output(url, view.to_html)
  end

  def render_payload_json
    view = PayloadJsonGenerator.new(blog: @blog)
    url = "/payload.json"
    write_output(url, view.to_json)
  end

  def render_tags_pages
    blog.data_manager.not_nil!.tags.not_nil!.each do |tag|
      download_image_if_needed(local: tag.image_url, remote: tag.header_ext_img)
      view = TagView.new(blog: @blog, tag: tag)
      write_output(tag.url, view.to_html)
    end
    @logger.info("Renderer: Tags finished")
  end

  def render_lands_pages
    blog.data_manager.not_nil!.lands.not_nil!.each do |land|
      download_image_if_needed(local: land.image_url, remote: land.header_ext_img)
      view = LandView.new(blog: @blog, land: land)
      write_output(land.url, view.to_html)
    end
    @logger.info("Renderer: Lands finished")
  end

  def render_towns_pages
    blog.data_manager.not_nil!.towns.not_nil!.each do |town|
      download_image_if_needed(local: town.image_url, remote: town.header_ext_img)
      view = TownView.new(blog: @blog, town: town)
      write_output(town.url, view.to_html)
    end
    @logger.info("Renderer: Towns finished")
  end

  def render_posts
    blog.post_collection.posts.each do |post|
      render_post(post)
    end
    @logger.info("Renderer: Posts finished")
  end

  def render_post(post : Tremolite::Post)
    view = PostView.new(blog: @blog, post: post)
    write_output(post.url, view.to_html)
  end

  def render_more_page
    view = MarkdownPageView.new(
      blog: @blog,
      file: "more",
      image_path: @blog.data_manager.not_nil!["more.backgrounds"],
      title: @blog.data_manager.not_nil!["more.title"],
      subtitle: @blog.data_manager.not_nil!["more.subtitle"]
    )
    url = "/more"
    write_output(url, view.to_html)
  end

  def render_about_page
    view = MarkdownPageView.new(
      blog: @blog,
      file: "about",
      image_path: @blog.data_manager.not_nil!["about.backgrounds"],
      title: @blog.data_manager.not_nil!["about.title"],
      subtitle: @blog.data_manager.not_nil!["about.subtitle"]
    )
    url = "/about"
    write_output(url, view.to_html)
  end
end
