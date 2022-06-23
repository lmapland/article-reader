require 'optparse'
require 'net/http'
require 'uri'
require 'time'
require 'nokogiri'

def get_article(opts)
  # Get the article
  res = Net::HTTP.get URI(opts[:article])

  # Choose a file name to write the file to
  # Turn an invalid filename into a valid one
  fn = opts[:name]
  if fn.nil?
    fn = Time.new.to_i
  else
    fn.gsub!(/[^0-9A-Za-z.\-]/, '_')
  end

  # Write article to file
  f = File.open("output/#{fn}.txt", "w")
  f.write(res)
  f.close

  puts "URL data has been written to #{fn}.txt"
  return "#{fn}"
end

def parse_article(fn, to_save)
  # Parse file into text
  article_text = ""
  html = File.open("output/#{fn}.txt") { |f| Nokogiri::HTML(f) }

  type1 = html.css('.StoryBodyCompanionColumn')
  if !type1.empty?
    type1.each do |e|
      e.children.children.each do |i|
        article_text << i.content.to_s << "\n\n"
      end
    end
  else
    type2 = html.css('.g-fg', '.g-body')
    if !type2.empty?
      type2.each do |e|
        article_text << e.content.to_s << "\n\n"
      end
    else
      type3 = html.css('.ArticleParagraph_root__wy3UI')
      if !type3.empty?
        type3.each do |e|
          article_text << e.content.to_s << "\n\n"
        end
      end
    end
  end

  # Write parsed text into file
  f = File.open("output/#{fn}_text.txt", "w")
  f.write(article_text)
  f.close

  # Delete the original html unless the user has chosen to save it
  if(nil == to_save)
    File.delete("output/#{fn}.txt")
  end

  puts "Article has been parsed to output/#{fn}_text.txt"
end

# Set up options
options = {}

option_parser = OptionParser.new do |opts|
  opts.banner = "Usage: ruby ./reader.rb [-a|--article] <url>"
  opts.on("-a", "--article url", "An article url is required.") do |a|
    options[:article] = a
  end

  opts.on("-n", "--name filename", "The file name of the output file.") do |n|
    options[:name] = n
  end

  opts.on("-s", "Saves a copy of the downloaded html") do |n|
    options[:save] = s
  end
end

option_parser.parse!

# This option is required!
if options[:article].nil?
  puts option_parser.banner
  exit 1
end

fn = get_article(options)

parse_article(fn, options[:save])
