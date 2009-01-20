class VideoReport < Report
  def url
    source_url || reporter.photo_urlformat(uniqueid)
  end
  
  def retweet_as
    "#{reporter.displayname}: #{title}"
  end
end
