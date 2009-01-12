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
      p find_tag(@tags)
      sleep POLL_INTERVAL
    end
  end
  
end

YoutubePoller.new("inaug09|dctrip09|inaugurationreport")

