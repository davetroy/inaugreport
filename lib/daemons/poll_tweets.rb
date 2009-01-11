ENV["RAILS_ENV"] ||= defined?(Daemons) ? 'production' : 'development'

# FIXME: pull in the platform.yml for the tag(s)
FEED = "http://twittervision.com/inaugreport.json"
EXTRACTOR = Regexp.new(/^(\w+?):\s(.*)$/m)

require File.dirname(__FILE__) + "/../../config/environment"
require 'json'
require 'open-uri'

$running = true
Signal.trap("TERM") do 
  $running = false
end

while($running) do
  tweets = JSON.parse(open(FEED).read)
  tweets.each do |entry|
    user_info = entry['source']['author']
    {'twitter_id' => 'uniqueid', 'location' => 'profile_location'}.each do |k,v|
      user_info[v] = user_info.delete(k)
    end
    next unless reporter = TwitterReporter.update_or_create(user_info)

    screen_name, text = entry['title'].match(EXTRACTOR).captures
<<<<<<< HEAD:lib/daemons/poll_tweets.rb
    reporter.reports.create(:body => text,
=======
    reporter.text_reports.create(:body => text,
>>>>>>> 8b4d8e33e265c5eea81a3eb5722336b34014cef4:lib/daemons/poll_tweets.rb
                        :uniqueid => entry['status_id'],
                        :created_at => entry['published'])
  end
  sleep 10
end

