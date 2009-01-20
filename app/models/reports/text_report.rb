class TextReport < Report

  def retweet_as
    "#{reporter.displayname}: #{title}"
  end
end
