class Article
  def initialize(url, name, to_save)
    @url = url
    @name = format_name(name)
    @to_save = to_save
    @downloaded = false
    @prefix = 'output/'
  end

  def values
    puts "url: #{@url}, name: #{@name}, to_save: #{@to_save}, prefix: #{@prefix}"
  end

  # Choose a file name to write the file to
  # Turn an invalid filename into a valid one
  def format_name(name)
    if name.empty?
      Time.new.to_i
    else
      name.gsub(/[^0-9A-Za-z.\-]/, '_')
    end
  end

  def download
    if @downloaded
      puts "File is already downloaded. Will not attempt to re-download"
      return
    end

    begin
      res = Net::HTTP.get URI(@url)
    rescue => e
      puts "Couldn't download the given file: #{e}"
      return false
    end

    File.open("#{@prefix}#{@name}.txt", "w") { |f| f.write(res) }

    puts "URL data has been written to #{@prefix}#{@name}.txt"

    @downloaded = true

    true
  end

  def parse
    if !@downloaded
      puts "File must be downloaded before it can be parsed"
    end

    article_text = ""
    html = File.open("#{@prefix}#{@name}.txt") { |f| Nokogiri::HTML(f) }

    elements = html.css('.ArticleParagraph_root__wy3UI')
    if !elements.empty?
      elements.each do |e|
        article_text << e.content.to_s << "\n\n"
      end
    end

    # Write parsed text into file
    File.open("#{@prefix}#{@name}_text.txt", "w") { |f| f.write(article_text) }

    puts "Article has been parsed to #{@prefix}#{@name}_text.txt"
  end

  def cleanup
    File.delete("#{@prefix}#{@name}.txt")
    @downloaded = false
  end

  def perform
    return if !download
    parse
    cleanup unless @to_save
  end
end
