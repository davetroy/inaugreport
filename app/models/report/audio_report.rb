class AudioReport < Report
  def filename
    "#{uniqueid}.#{filetype}"
  end
end
