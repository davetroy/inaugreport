# Simple Youtube Polling daemon
# (C) 2009 David Troy, dave@roundhousetech.com

#!/usr/bin/env ruby

ENV["RAILS_ENV"] ||= defined?(Daemons) ? 'production' : 'development'

require File.dirname(__FILE__) + "/../../config/environment"
%w{ rubygems json open-uri youtube }.each {|gem| require gem}

class YoutubePoller
  include Youtube
  POLL_INTERVAL = 30

  def initialize(tags)
    @tags = tags
    @running = true
    Signal.trap("TERM") { @running = false }
    poll
  end

  def poll
    while (@running) do
      doc = find_tag(@tags)
      doc['feed']['entry'].each do |e|
        begin
          next unless e && e['id'] && e.is_a?(Hash) 
          p e['id']
        rescue
          next
        end
      end
      sleep POLL_INTERVAL
    end
  end
  
end

YoutubePoller.new("inaug09|dctrip09|inaug|dctrip09")

