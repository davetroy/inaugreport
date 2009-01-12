# Simple Flickr Polling daemon
# (C) 2009 David Troy, dave@roundhousetech.com

#!/usr/bin/env ruby

ENV["RAILS_ENV"] ||= defined?(Daemons) ? 'production' : 'development'

require File.dirname(__FILE__) + "/../../config/environment"
%w{ rubygems json open-uri flickr }.each {|gem| require gem}

class FlickrPoller
  include Flickr
  POLL_INTERVAL = 30

  def initialize(tags)
    @tags = tags
    @running = true
    Signal.trap("TERM") { @running = false }
    poll
  end

  def poll
    while (@running) do
      process_feed(photos_search(:tags => @tags, :tag_mode => "any"))
      sleep POLL_INTERVAL
    end
  end
  
  def process_feed(plist, feed_name=nil)
    list = plist['photos']['photo']
    list.each do |p|
      id = p['id']
      puts "photo #{id}"
      next if PhotoReport.find_by_uniqueid(id)
      pi = photos_getInfo(:photo_id => id)
      next unless pi['photo']
      owner = pi['photo']['owner']
      u = FlickrReporter.update_or_create(:uniqueid => owner['nsid'], :name => owner['realname'], :screen_name => owner['username'], :profile_location => owner['location'])
      p pi['photo']
      # sz = photos_getSizes(:photo_id => id)
      # next unless sz['sizes'] && p = u.add_photo(pi['photo'], sz['sizes']['size'], feed_name)
      # puts "added photo #{p.id} to user #{u.id}"
    end
  end
end

FlickrPoller.new("inaug09,dctrip,dctrip09")

