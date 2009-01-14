class YoutubeReporter < Reporter

  def source; "YouTube"; end
  def source_name; "YouTube"; end
  def icon; "/images/youtube_icon.png"; end
  def display_name; name || screen_name; end
  
end
