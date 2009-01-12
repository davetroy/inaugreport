class SmsReporter < Reporter

  def source_name; "SMS"; end
  def source; "SMS"; end
  def icon; profile_image_url || "http://www.mozes.com/_common/images/default_avatars/phone_default_0.jpg"; end

  def display_name; screen_name || "SMS User"; end
end
