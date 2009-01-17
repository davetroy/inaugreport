# ActionMailer receiver for reports submitted via email
class Receiver < ActionMailer::Base
  def receive(email)
    user_info = { :uniqueid => email.from,
                  :screen_name => email.from,
                  :name => email.friendly_from }
        
    email.each_part do |part|
      info['reporter'] = user_info
      report_info = { :title => email.subject }
    end
  end

  

end
