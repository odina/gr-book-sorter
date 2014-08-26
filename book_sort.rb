require 'goodreads'
require 'optparse'
require 'yaml'

module BookSort

  def self.run!(argv)
    options = parse_options(argv)

    init!(options.delete(:config))

    search options
  end

  def self.init!(config)
    config ||= 'config.yml'

    path = File.join(File.dirname(__FILE__), config)

    @config = YAML.load_file path
    @config.symbolize_keys!
  end

  def self.search(options = {})
    client  = Goodreads::Client.new(:api_key => @config[:key])
    results = []
    sorted  = {}

    (1..options[:page_count]).each do |count|
      search  = client.search_books(options[:query])
      results << search.results.work
    end

    results.flatten.each do |r|
      sorted["#{r.average_rating}"] = r
    end

    sorted.each do |k,v|
      puts "Title: #{v.best_book.title}"
      puts "Author: #{v.best_book.author.name}"
      puts "Ave. Rating: #{v.average_rating}"
      puts "Ratings count: #{v.ratings_count}"
      puts "\n"
    end
  end

  def self.parse_options(argv)
    options = {}

    OptionParser.new do |o|
      o.on('-q QUERY', '--query', 'Book title to query') do |q|
        options[:query] = q
      end

      o.on('-c COUNT', '--count', 'Page count (defaults to page 5)') do |c|
        options[:page_count] = c.to_i
      end

      o.on('-h', '--help', 'Display this screen') do
        puts o
        exit
      end

    end.parse!

    options[:page_count] ||= 1

    options
  end

end
