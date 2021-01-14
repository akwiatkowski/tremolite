class Tremolite::Views::AbstractView
  Log = ::Log.for(self)

  # by default everything will be added to sitemap.xml
  def add_to_sitemap?
    true
  end
end
