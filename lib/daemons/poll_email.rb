# Simple Email Polling daemon
# (C) 2009 David Troy, dave@roundhousetech.com

#!/usr/bin/env ruby

ENV["RAILS_ENV"] ||= defined?(Daemons) ? 'production' : 'development'

require File.dirname(__FILE__) + "/../../config/environment"

MAILSPOOL = RAILS_ENV=='production' ? "/home/inaugreport/Maildir/cur" : File.dirname(__FILE__) + "/../../test/fixtures/receiver"

$running = true; Signal.trap("TERM") { $running = false }

while ($running) do
  Dir.glob("#{MAILSPOOL}/*").each do |d|
    Receiver.receive(File.read(d))
    File.delete(d) if RAILS_ENV=='production'
  end
  sleep 15
end
