require "yaml"

alias TownEntityHash = Hash(String, String | Array(String))

struct TownEntity
  @slug : String
  @name : String
  @type : String
  @header_ext_img : String

  @voivodeship : String | Nil

  getter :name, :slug, :voivodeship

  def initialize(y : YAML::Any)
    @slug = y["slug"].to_s
    @name = y["name"].to_s
    @type = y["type"].to_s

    @header_ext_img = y["header-ext-img"].to_s

    if y["inside"]?
      @voivodeship = y["inside"][0].to_s
    end

    @voivodeship = y["voivodeship"].to_s if y["voivodeship"]?
  end

  def to_hash
    h = TownEntityHash.new
    h["slug"] = @slug.to_s unless @slug.nil?
    h["name"] = @name.to_s unless @name.nil?
    h["header-ext-img"] = @header_ext_img.to_s unless @header_ext_img.nil?
    h["type"] = @type.to_s unless @type.nil?
    h["voivodeship"] = @voivodeship.to_s unless @voivodeship.nil?

    return h
  end

  def is_town?
    return @type == "town"
  end

  def is_voivodeship?
    return @type == "voivodeship"
  end
end

# class TownGenerator
#   def initialize
#     @path = File.join(["_data", "internal"])
#     @out_path = File.join(["_data", "towns.yml"])
#     @towns = Array(TownEntity).new
#     @voivodeships = Array(TownEntity).new
#   end
#
#   def make_it_so
#     # load_voivodeships
#     # scan_towns
#     scan_all_files
#     save_output
#
#     save_by_voivodeship
#
#     create_town_md_files
#   end
#
#   def scan_all_files
#     Dir[File.join([@path, "**", "*"])].each do |f|
#       if File.file?(f)
#         load_yaml(f)
#       end
#     end
#   end
#
#   def load_yaml(f)
#     puts "Loading #{f}"
#
#     YAML.parse(File.read(f)).each do |town|
#       o = TownEntity.new(town)
#       @towns << o if o.is_town?
#       @voivodeships << o if o.is_voivodeship?
#     end
#
#     @towns = @towns.sort{|a,b| a.slug <=> b.slug }.uniq{|a| a.slug}
#     @voivodeships = @voivodeships.sort{|a,b| a.slug <=> b.slug }.uniq{|a| a.slug}
#   end
#
#   def scan_towns
#     Dir[File.join([@path, "towns", "*"])].each do |f|
#       load_town_yaml(f)
#     end
#   end
#
#   def save_output
#     ta = Array(TownEntityHash).new
#
#     @voivodeships.each do |v|
#       ta << v.to_hash
#     end
#     @towns.each do |t|
#       ta << t.to_hash
#     end
#
#     f = File.new(@out_path, "w")
#     f.puts(ta.to_yaml)
#     f.close
#
#     puts "Saved total - #{ta.size}"
#   end
#
#   def save_by_voivodeship
#     @voivodeships.each do |v|
#       f = File.new(File.join([@path, "towns", "#{v.slug}.yml"]), "w")
#       ta = Array(TownEntityHash).new
#
#       @towns.select{|t| t.voivodeship == v.slug }.each do |t|
#         ta << t.to_hash
#       end
#
#       f.puts(ta.to_yaml)
#       f.close
#
#       puts "Save #{v.slug} - #{ta.size}"
#     end
#   end
#
#   def create_town_md_files
#     @towns.each do |t|
#       create_town_md_file(t.slug)
#     end
#   end
#
#   def create_town_md_file(town : String)
#     p = File.join(["town", "#{town}.md"])
#     if File.exists?(p)
#       # nothing
#     else
#       s = "---\nlayout: blog_by_town\ntown: #{town}\npermalink: /town/#{town}/\n---"
#       f = File.new(p, "w")
#       f.puts(s)
#       f.close
#     end
#   end
#
# end
#
# tg = TownGenerator.new
# tg.make_it_so
#
# sleep 0.2
