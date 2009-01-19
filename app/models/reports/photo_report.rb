class PhotoReport < Report
  before_create :make_thumbnails
  
  THUMBNAIL_SIZE = 180
  
  def filename(size=nil)
    "#{AUDIO_UPLOAD_PATH}/#{uniqueid}#{size}.#{reporter.photo_filetype}"
  end
  
  # Either we've predefined a source URL for this image, or
  # our reporter knows how to make one from our uniqueid
  def url
    source_url || reporter.photo_urlformat(uniqueid, 's')
  end

  # Makes thumbnails if ImageMagick is available
  def make_thumbnails
    return true unless defined?(IMAGEMAGICK_CONVERT)
    system("#{IMAGEMAGICK_CONVERT} -resize #{THUMBNAIL_SIZE} #{filename} #{filename('s')}")
    true
  end
end
