class PhotoReport < Report
  before_create :make_thumbnails
  
  named_scope :stored_locally, :conditions => '(reports.source IS NULL OR LEFT(reports.source,1)="/")'
  
  THUMBNAIL_SIZE = 180
  
  def filename(size=nil)
    "#{AUDIO_UPLOAD_PATH}/#{uniqueid}#{size}.#{reporter.photo_filetype}"
  end
  
  # Either we've predefined a source URL for this image, or
  # our reporter knows how to make one from our uniqueid
  def url
    source_url || reporter.photo_urlformat(uniqueid, 's')
  end

  def is_local?
    source.nil? || source.first == '/'
  end
  
  # Makes thumbnails if ImageMagick is available and we have local storage
  def make_thumbnails
    return true unless defined?(IMAGEMAGICK_CONVERT) && is_local?
    system("#{IMAGEMAGICK_CONVERT} -resize #{THUMBNAIL_SIZE} #{filename} #{filename('s')}")
    true
  end
end
