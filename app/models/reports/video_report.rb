class VideoReport < Report
  def url
    source_url || reporter.photo_urlformat(uniqueid)
  end
end
