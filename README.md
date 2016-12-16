# tremolite

Customized blog-like static pages generator.

`tremolite` goal is to be more customizable, faster,
and more explicit [Jekyll](https://jekyllrb.com/) alternative.

I have started
thinking about it after my blog needs more than 30 seconds to render and
I had to put some very advanced hacks to meet my needs.

[Jekyll](https://jekyllrb.com/) is a great way to start.
[Liquid templates](https://jekyllrb.com/docs/templates/) allow to customize
without need to write Ruby code. In `tremolite` you will have to write
`Crystal` code.

## Roadmap

1. [ ] Copy [my blog in Jekyll](http://odkrywajacpolske.pl/) features:
  * [x] Index
  * [x] Paginated list
  * [x] Header image resize
  * [ ] Force images to be exactly 600x400
  * [ ] Post summary JSON - partially
  * [ ] Summary
  * [ ] Pois
  * [ ] Remove gallery, link to smugmug, 500px, panoramio dead (ugly google)
  * [ ] Plans / TODO
  * [ ] Planner
  * [x] Tags pages
  * [ ] Tags list
  * [ ] Tags post field
  * [x] Lands pages
  * [ ] Lands list
  * [x] Towns pages
  * [ ] Towns list
  * [ ] About: check this http://kolejnapodroz.pl/blogu/
  * [ ] Town statistics
  * [ ] Get list of towns
  * [ ] RSS/Atom
  * [ ] RSS/Atom by tags

2. [ ] Upgrade to power of the Crystal :]
  * [ ] Analyze size of summary and details JSON - check if details are needed
  * [ ] Post details in JSON - route, ...
  * [ ] Very small thumb 64x64 as base64 in post summary JSON

3. [ ] `tremolite` as a lib
  * [ ] Remove custom code to another repo
  * [ ] Readme

## Installation


Add this to your application's `shard.yml`:

```yaml
dependencies:
  tremolite:
    github: akwiatkowski/tremolite
```


## Usage


```crystal
require "tremolite"
```


TODO: Write usage instructions here

## Development

TODO: Write development instructions here

## Contributing

1. Fork it ( https://github.com/akwiatkowski/tremolite/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [akwiatkowski](https://github.com/akwiatkowski) Aleksander Kwiatkowski - creator, maintainer
