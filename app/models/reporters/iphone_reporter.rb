class IphoneReporter < Reporter
  before_save :map_fields

  attr_accessor :firstname, :lastname, :zipcode, :email

  validates_format_of :uniqueid, :with => /^[\d\-A-F]{36,40}$/i, :on => :create, :message => "Invalid UDID"
    
  def source_name; "#{APP_NAME} iPhone App"; end
  def icon; "/images/iphone_icon.png"; end
  def audio_path; "#{PLATFORM_CONFIG["iphone_url"]}/audio"; end
  def audio_filetype; "caf"; end
  def photo_filetype; "jpg"; end

  private
  def map_fields
    self.name = "#{self.firstname} #{self.lastname}"
    self.profile_location = self.zipcode
    self.screen_name = self.email
  end
    
end
