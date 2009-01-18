# ActionMailer receiver for reports submitted via email
class Receiver < ActionMailer::Base
  def receive(email)
    user_info = { 'uniqueid' => email.from.first,
                  'screen_name' => email.from.first,
                  'name' => email.friendly_from }
    reporter = EmailReporter.update_or_create(user_info)
    puts "email from #{reporter.name}"
    
    if email.parts.size.zero?
      reporter.text_reports.create(:title => email.subject, :body => email.body)
      return true
    end
    
    parent_report_id = nil
    email.each_part do |part|
      report_info = { :title => email.subject, :parent_report_id => parent_report_id }
      case part.content_type
        when /text/
          report = reporter.text_reports.create(report_info.merge(:body => part.unquoted_body))
        when /image/
          report = reporter.photo_reports.create(report_info)
          save_part(report, part, '/photos')
        when /audio/
          report = reporter.audio_reports.create(report_info)
          save_part(report, part, '/audio')
        else
          report = reporter.text_reports.create(report_info.merge(:body => part.unquoted_body))
      end
      parent_report_id ||= report.id
    end
  end

  private
  def save_part(report, part, urlpath)
    filename = "#{report.uniqueid}.#{part.disposition_param('filename')}"
    File.open("#{AUDIO_UPLOAD_PATH}/#{filename}", 'w') { |f| f.write part.body }
    report.update_attributes(:source_url => "#{urlpath}/#{filename}")
  rescue
    nil
  end
end
