class PhotoReport < Report
  def filename
    "#{AUDIO_UPLOAD_PATH}/#{uniqueid}.#{reporter.photo_filetype}"
  end
  
  # Either we've predefined a source URL for this image, or
  # our reporter knows how to make one from our uniqueid
  def url
    source_url || reporter.photo_urlformat(uniqueid)
  end
  
  def retweet_as
    "#{reporter.displayname}: #{title}"
  end

end
