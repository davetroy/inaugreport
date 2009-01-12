class PhotoReport < Report
  def filename
    "#{AUDIO_UPLOAD_PATH}/#{uniqueid}.#{reporter.photo_filetype}"
  end
  
  def url
    source_url || reporter.urlformat(uniqueid)
  end

end
