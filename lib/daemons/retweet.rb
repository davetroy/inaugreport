ENV["RAILS_ENV"] ||= defined?(Daemons) ? 'production' : 'development'

URL =  "http://twitter.com/statuses/update.xml"
LAST_ID_FILE =   File.dirname(__FILE__) + "/../../shared/config/last_tweeted_id"

options = YAML.load(
  ERB.new(
  IO.read(
  File.dirname(__FILE__) + "/../../shared/config/twitter_account.yml"
  )).result)

if ENV["RAILS_ENV"] == 'development'
  # Dev
  USERNAME = options["development"]["username"]
  PASSWORD = options["development"]["password"]
  CURL = "/usr/bin/curl" # Silly macs "/opt/local/bin/curl"
else
  # Prod
  USERNAME = options["production"]["username"]
  PASSWORD = options["production"]["password"]
  CURL = "/usr/bin/curl"
end

require File.dirname(__FILE__) + "/../../config/environment"

$running = true
Signal.trap("TERM") do
  $running = false
end

def format_tweet(tweet)
  tweet.length > 140 ? tweet[0..136] + '...' : tweet
end

def tweet(orig_tweet)
  tweet = format_tweet(orig_tweet)
  system CURL, "-u", "#{USERNAME}:#{PASSWORD}", "--data-urlencode", "status=#{tweet}", URL
end

while($running) do
#  if File.exists?("/tmp/tweet.txt")
#    msg = IO.read("/tmp/tweet.txt")
#    msg = tweet_format(msg)
#    puts "tweet: " + msg
#    tweet(msg)
#    File.delete("/tmp/tweet.txt")
#  end

  last_tweeted_id ||= File.read(LAST_ID_FILE) rescue Report.last.id

  Report.all(:conditions => ["id > ?", last_tweeted_id], :limit => 50).each do |r|
    # would rather not tweet than double tweet
    last_tweeted_id = r.id

    tweet(r.display_text)
  end

  File.open(LAST_ID_FILE, "w") { |f| f.print last_tweeted_id }

  sleep 10
end

