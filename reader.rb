require 'optparse'
require 'net/http'
require 'uri'

# Set up options
options = {}

option_parser = OptionParser.new do |opts|
  opts.banner = "Usage: ruby ./reader.rb [-a|--article] <url>"
  opts.on("-a", "--article url", "An article url is required.") do |a|
    options[:article] = a
  end
end

option_parser.parse!

# This option is required!
if options[:article].nil?
  puts option_parser.banner
  exit 1
end

# Get the article
res = Net::HTTP.get URI(options[:article])

# Write article to file
# Todo: make filename dynamic / give ability to pass it in
f = File.open("output/article.txt", "w")
f.write(res)
f.close
