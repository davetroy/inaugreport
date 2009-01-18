class EmailReporter < Reporter

  def source_name; "Email"; end
  def source; "Email"; end
  def icon; "/images/email_icon.jpg"; end
  def display_name; name || "Email User"; end
  
end
