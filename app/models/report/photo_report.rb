class PhotoReport < Report
  def filename
    "#{uniqueid}.#{filetype}"
  end
end
