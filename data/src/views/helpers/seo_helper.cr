class BaseView
  def site_url
    @blog.data_manager.not_nil!["site.url"]
  end

  def author_string
    @blog.data_manager.not_nil!["site.author"]
  end


  def meta_keywords_string
    ""
  end

  def meta_description_string
    ""
  end

  def page_desc
    ""
  end

  def current_url
    ""
  end

  def current_full_url
    # TODO add to errors if `current_url` is blank
    site_url + current_url
  end

  def robots_string
    "index, follow"
  end

  def build_seo_html
    s = ""

    h = {
      "keywords" => meta_keywords_string,
      "description" => meta_description_string,
      "author" => author_string,
      "robots" => robots_string,
      "og:title" => title,
      "og:description" => meta_description_string,
      "og:url" => current_full_url,
      "og:site_name" => site_title
    }

    h.each do |k, v|
      if v.to_s != ""
        s += "<meta name=\"#{k}\" content=\"#{v}\">\n"
      end
    end

    return s
  end

  def build_seo_ld_json
    "<script type=\"application/ld+json\">
    {\"@context\": \"http://schema.org\",
    \"@type\": \"WebPage\",
    \"headline\": \"#{title}\",
    \"description\": \"#{page_desc}\",
    \"url\": \"#{current_full_url}\"}</script>\n"
  end

  def seo_html
    build_seo_html + build_seo_ld_json
  end
end
