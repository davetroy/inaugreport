class EmailReporter < Reporter

  def source_name; "Email"; end
  def source; "Email"; end
  def icon; "/images/email_icon.jpg"; end
  def name; screen_name || "Email User"; end
  
end
