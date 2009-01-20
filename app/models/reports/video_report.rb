class VideoReport < Report
  def url
    source_url
  end
  
  def retweet_as
    "#{reporter.displayname}: #{title}"
  end
end
