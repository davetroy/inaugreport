class EmailReporter < Reporter
  before_create :initialize_location

  def source_name; "Email"; end
  def source; "Email"; end
  def icon; "/images/email_icon.jpg"; end
  def name; screen_name || "Email User"; end

  # TODO: this concept is broken for this reporter
  def audio_filetype; "mp3"; end
  def photo_filetype; "jpg"; end
  
  private
  def initialize_location
    self.location = Location.geocode(self.profile_location) if self.profile_location.is_a?(String) && !self.profile_location[/\d{10}/]
  end
end
