class PhotoReport < Report
  def filename
    "#{AUDIO_UPLOAD_PATH}/#{uniqueid}.#{reporter.photo_filetype}"
  end
  
  def url
    # if reporter.is_a?(FlickrReporter)
    #   ""
    "/photos/#{uniqueid}.#{reporter.photo_filetype}"
  end
end
