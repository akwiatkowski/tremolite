class Tremolite::Views::AbstractView
  Log = ::Log.for(self)

  # by default everything is ready and will be added to sitemap.xml
  def ready
    true
  end
end
