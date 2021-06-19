require 'optparse'
require 'net/http'
require 'uri'
require 'time'

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
end

option_parser.parse!

# This option is required!
if options[:article].nil?
  puts option_parser.banner
  exit 1
end

# Get the article
res = Net::HTTP.get URI(options[:article])

# Choose a file name to write the file to
# Turn an invalid filename into a valid one
fn = options[:name]
if fn.nil?
  fn = Time.new.to_i
else
  fn.gsub!(/[^0-9A-Za-z.\-]/, '_')
end

fn << ".txt"

# Write article to file
f = File.open("output/#{fn}", "w")
f.write(res)
f.close

puts "URL data has been written to #{fn}"
