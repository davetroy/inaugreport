class PhotoReport < Report
  
  named_scope :stored_locally, :conditions => '(reports.source_url IS NULL OR LEFT(reports.source_url,1)="/")'
  
  THUMBNAIL_SIZE = 180
  
  def filename(size=nil)
    "#{AUDIO_UPLOAD_PATH}/#{uniqueid}#{size}.#{reporter.photo_filetype}"
  end
  
  # Either we've predefined a source URL for this image, or
  # our reporter knows how to make one from our uniqueid
  def url
    source_url || reporter.photo_urlformat(uniqueid, 's')
  end
  
  def large_url
    reporter.photo_urlformat(uniqueid)
  end

  def is_local?
    source_url.nil? || source_url.first == '/'
  end
  
  # Makes thumbnails if ImageMagick is available and we have local storage
  def make_thumbnails
    return true unless defined?(IMAGEMAGICK_CONVERT) && is_local?
    system("#{IMAGEMAGICK_CONVERT} -resize #{THUMBNAIL_SIZE} #{filename} #{filename('s')}")
    true
  end
end
