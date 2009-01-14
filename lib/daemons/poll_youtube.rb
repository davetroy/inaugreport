# Simple Youtube Polling daemon
# (C) 2009 David Troy, dave@roundhousetech.com

#!/usr/bin/env ruby

ENV["RAILS_ENV"] ||= defined?(Daemons) ? 'production' : 'development'
ID_EXTRACT = Regexp.compile(/\/(\w+$)/)

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

          u = get_user(e['author']['name'])['entry']
          u_attrs = { 'uniqueid' => u['username'],
                      'screen_name' => u['username'],
                      'name' => u['firstName'],
                      'profile_image_url' => u['thumbnail']['url'] }
          
          attrs = { 'title' => e['title'],
                    'body' => e['content'],
                    'uniqueid' => e['id'][ID_EXTRACT,1],
                    'created_at' => e['published'],
                    'source_url' => e['group']['thumbnail'][0]['url'] }

          if e['where']
            attrs['location_name'] = e['where']['Point']['pos'].gsub(' ', ', ')
          else
            attrs['location_name'] = u['location'] || u['hometown']
          end
          
          reporter = YoutubeReporter.update_or_create(u_attrs)
          reporter.video_reports.create(attrs)
          
        # rescue
        #   next
        end
      end
      sleep POLL_INTERVAL
    end
  end
  
end

YoutubePoller.new("inaug09|dctrip09|inaug")

