class PhoneReporter < Reporter
  before_create :initialize_location
  
  def source_name; "Telephone"; end
  def source; "Phone"; end
  def icon; "/images/phone_icon.jpg"; end
  def audio_path; PLATFORM_CONFIG["audio_path"]; end
  def name; screen_name || "Telephone User"; end
  def audio_filetype; "gsm"; end
  
  private
  def initialize_location
    self.location = Location.geocode(self.profile_location) if self.profile_location.is_a?(String) && !self.profile_location[/\d{10}/]
  end
end
