require "../src/tremolite"

t = Tremolite::Blog.new
t.refresh
t.server.run
