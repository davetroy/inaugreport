class AndroidReporter < Reporter
  before_save :map_fields
  
  attr_accessor :firstname, :lastname, :zipcode, :email
  
  validates_format_of :uniqueid, :with => /^\d{14,16}/, :on => :create, :message => "Invalid IMEI"
    
  def source_name; "#{APP_NAME} Android App"; end
  def source; "Android"; end
  def icon; "/images/android_icon.png"; end
  def audio_path; "#{PLATFORM_CONFIG["iphone_url"]}/audio"; end
  def audio_filetype; "3gp"; end
  def photo_filetype; "jpg"; end

  def display_name; name; end

  def photo_urlformat(uniqueid)
    "/photos/#{uniqueid}.#{photo_filetype}"
  end
  
  private
  def map_fields
    if (self.firstname && self.lastname)
      self.name = "#{self.firstname} #{self.lastname}"
      self.profile_location = self.zipcode
      self.screen_name = self.email
    end
    true
  end
end
