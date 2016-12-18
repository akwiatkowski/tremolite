require "./views/home_view"
require "./views/paginated_post_list_view"
require "./views/map_view"
require "./views/payload_json_generator"

class Tremolite::Renderer
  def render_all
    render_index
    render_posts
    render_paginated_list
    render_map
    render_more_page
    render_payload_json
    render_tags_pages
    render_lands_pages
    render_towns_pages
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

  #####

  def render_more_page
    view = Tremolite::Views::MoreView.new(blog: @blog)
    url = "/more"
    write_output(url, view.to_html)
  end



  def render_tags_pages
    blog.data_manager.not_nil!.tags.each do |tag|
      # download and process image
      # processing is not needed now
      full_image_path = File.join(["data", tag.image_path])
      if false == File.exists?(full_image_path)
        ImageResizer.download_image(source: tag.header_ext_img, output: full_image_path)
      end

      view = Tremolite::Views::TagView.new(blog: @blog, tag: tag)
      write_output(tag.url, view.to_html)
    end
    @logger.info("Renderer: Tags finished")
  end

  def render_lands_pages
    blog.data_manager.not_nil!.lands.each do |land|
      # download and process image
      # processing is not needed now
      full_image_path = File.join(["data", land.image_path])
      if false == File.exists?(full_image_path)
        ImageResizer.download_image(source: land.header_ext_img, output: full_image_path)
      end

      view = Tremolite::Views::LandView.new(blog: @blog, land: land)
      write_output(land.url, view.to_html)
    end
    @logger.info("Renderer: Lands finished")
  end

  def render_towns_pages
    blog.data_manager.not_nil!.towns.each do |town|
      html_output_path = convert_url_to_local_path_with_public(town.url)
      Dir.mkdir_p_dirname(html_output_path)

      # download and process image
      # processing is not needed now
      full_image_path = File.join(["data", town.image_path])
      if false == File.exists?(full_image_path)
        ImageResizer.download_image(source: town.header_ext_img, output: full_image_path)
      end

      view = Tremolite::Views::TownView.new(blog: @blog, town: town)
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
    view = Tremolite::Views::PostView.new(blog: @blog, post: post)
    write_output(post.url, view.to_html)
  end
end
