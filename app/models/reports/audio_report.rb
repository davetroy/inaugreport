class AudioReport < Report
  def filename
    "#{AUDIO_UPLOAD_PATH}/#{uniqueid}.#{reporter.audio_filetype}"
  end
  
  def url
    "#{SERVER_URL}/audio/#{uniqueid}.#{reporter.audio_filetype}"
  end
end
