require "./site_layout"

class Tremolite::Layouts::PostLayout < Tremolite::Layouts::SiteLayout
  def initialize(@blog : Tremolite::Blog, @post : Tremolite::Post)
  end

  def content
    post_header_html +
      post_article_html
  end

  def post_header_html
    data = Hash(String, String).new
    data["post.image_url"] = @post.image_url
    data["post.title"] = @post.title
    data["post.subtitle"] = @post.subtitle
    data["post.author"] = @post.author
    data["post.date"] = @post.date
    return load_layout("post_header", data)
  end

  def post_article_html
    s = %q(<article>
        <div class="container">
        <div class="row">
                <div class="col-lg-8 col-lg-offset-2 col-md-10 col-md-offset-1">)

    s += @post.content_html

    s += %q(</div>
</div>
</div>
</article>

<hr>)

    return s
  end
end
