#!/usr/bin/env ruby

### Don't need to edit below here
%w{ rubygems hpricot open-uri }.each {|gem| require gem}
# e.g. ta = Twitterchive.new("inaug09", :fields => ["google:location"], :search => {:geocode => "38.892091%2C-77.024055%2C50mi"}, :paginate => false)

class Twitterchive
  attr_accessor :tag, :fields, :entries
  
  def initialize(tag, options = {})
    @tag = tag
    @additional_params = options.include?(:search) ? options[:search].collect {|k,v| "#{k}=#{v}"}.join("&") : "1=1"
    @fields = (["id","title", "published","author/name","author/uri"] + (options[:fields] || []) + ["link"]).flatten
    @paginate = options.include?(:paginate) ? options[:paginate] : true
    @entries = []
  end
  def fetch
    next_url = "http://search.twitter.com/search.atom?tag=#{@tag}&lang=all&rpp=50&#{@additional_params}"
    while (next_url)
      begin
        puts next_url
        doc = Hpricot.parse(open(next_url))

        @entries << (doc/:entry).collect do |entry|
          # don't get the link this way
          entry_h = {}
          @fields[0..@fields.length-2].collect {|f| entry_h[f] = (entry/f).inner_text }
          entry_h["link"] = (entry/"link").first["href"]
          entry_h
        end.split(",")
        next_url = @paginate ? (doc/"link[@rel=next]").first["href"] : nil
        sleep(0.2)
      rescue
        next_url = nil
      end
    end
    @entries.flatten!
  end

  def csv(filename = nil)
    File.open(filename || "#{@tag}.csv","w") do |file|
      file << @fields.join(",") + "\n"
      file << @entries.collect {|e| e.values.join(",")}.join("\n")
    end
  end
end

if __FILE__ == $0
  %w{ ostruct options }.each {|gem| require gem}
  # Parse the command line options
  options = OpenStruct.new
  opts = OptionParser.new
  opts.banner = "Usage: twitterchive.rb [options] archive_filename"
  opts.on("-t [tag]", "--tag [tag]", "Twitter hashtag to archive") {|tag| options.tag = tag }
  
  opts.on_tail("-h", "--help", "Show this message") do
    puts opts
    exit
  end
  file = opts.parse(ARGV)
  
  unless options.tag.nil? || options.tag == ""
    tag_archive = Twitterchive.new(options.tag)
    tag_archive.fetch
    tag_archive.csv(file.first)
  end
end