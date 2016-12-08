require "markdown"

text = "
[a]: http://google.pl
## This is title \n This is a [link][a]"

puts Markdown.to_html(text)

# Crystal Markdown not support referenced links so
# I need to write it
#
# brb soon
