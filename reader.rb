require 'optparse'
require 'net/http'
require 'uri'
require 'time'
require 'nokogiri'
require './article'

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

  opts.on("-s", "Saves a copy of the downloaded html") do |s|
    options[:save] = s
  end
end

option_parser.parse!

# This option is required!
if options[:article].nil?
  puts option_parser.banner
  exit 1
end


new_article = Article.new(options[:article], options[:name] || '', nil != options[:save])
new_article.perform
