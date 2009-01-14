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
      next unless doc['feed'] && doc['feed']['entry']
      doc['feed']['entry'].each do |e|
        begin
          next unless e && e['id'] && e.is_a?(Hash)

          u = get_user(e['author']['name'])['entry']
          profile_location = u['location'] || u['hometown']
          u_attrs = { 'uniqueid' => u['username'],
                      'screen_name' => u['username'],
                      'name' => u['firstName'],
                      'profile_image_url' => u['thumbnail']['url'],
                      'profile_location' => profile_location }

          attrs = { 'title' => e['title'],
                    'body' => e['content'],
                    'uniqueid' => e['id'][/([^\/]+)$/],
                    'created_at' => e['published'],
                    'source_url' => e['group']['thumbnail'][0]['url'],
                    'link_url' => e['link'][0]['href'] }

          if e['where']
            attrs['location_name'] = e['where']['Point']['pos'].gsub(' ', ',')
          else
            attrs['location_name'] = profile_location
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

YoutubePoller.new("inaug09|dctrip09")

