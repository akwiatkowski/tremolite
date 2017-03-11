# tremolite

Customized blog-like static pages generator.

`tremolite` goal is to be more customizable, faster,
and more explicit [Jekyll](https://jekyllrb.com/) alternative.

I have started
thinking about it after my blog needs more than 30 seconds to render and
Had to put some advanced hacks to meet my needs.

[Jekyll](https://jekyllrb.com/) is a great way to start.
[Liquid templates](https://jekyllrb.com/docs/templates/) allow to customize
without need to write Ruby code. In `tremolite` you will have to write
`Crystal` code which probably makes it harder to use at start.

[Ultra simple sample code is here](https://github.com/akwiatkowski/tremolite_example).
My blog [odkrywajacpolske.pl](https://github.com/akwiatkowski/akwiatkowski.github.com)
has much more features but it's not easy to read.

## Roadmap

3. [ ] `tremolite` as a lib
  * [x] Remove custom code to another repo
  * [ ] README

4. [ ] Some cool features
  * [x] Put all files into buffer and overwrite if something changes
  * [ ] Validate missing html links
  * [x] Validate missing references
  * [ ] Validate internal posts
  * [ ] FTP uploader who knows which file was changed
  * [x] Customizable view functions
  * [ ] Allow to disable copying all source images to `public` (ex. only header image)
  * [ ] Uglyfier

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
