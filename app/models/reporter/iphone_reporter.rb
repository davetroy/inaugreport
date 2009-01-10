class IphoneReporter < Reporter
  before_create :set_location
  validates_format_of :uniqueid, :with => /^[\d\-A-F]{36,40}$/i, :on => create, :message => "Invalid UDID"

  attr_accessor :latlon
  self.column_names << 'latlon'   # needed to keep Reporter happy
    
  def source_name; "#{APP_NAME} iPhone App"; end
  def icon; "/images/iphone_icon.png"; end
  def audio_path; "#{PLATFORM_CONFIG["iphone_url"]}/audio"; end
  def audio_filetype; "caf"; end
  
  private
  def set_location
    self.latlon, location_accuracy = self.latlon.split(/:/)
    if self.location = Location.geocode(self.latlon)
      self.profile_location = self.location.address if self.profile_location.nil?
    end
  end
end
