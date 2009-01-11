class AudioReport < Report
  def filename
    "#{AUDIO_UPLOAD_PATH}/#{uniqueid}.#{reporter.audio_filetype}"
  end
  
  def url
    "#{uniqueid}.#{reporter.audio_filetype}"
  end
end
