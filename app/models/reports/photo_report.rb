class PhotoReport < Report
  def filename
    "#{AUDIO_UPLOAD_PATH}/#{uniqueid}.#{reporter.photo_filetype}"
  end
  
  def url
    "/photos/#{uniqueid}.#{reporter.photo_filetype}"
  end
end
