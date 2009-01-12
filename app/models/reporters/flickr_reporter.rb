class FlickrReporter < Reporter

  def source_name; "Flickr"; end
  def source; "Flickr"; end
  def icon; "/images/flickr_icon.png"; end

  def display_name; screen_name || name; end
end
