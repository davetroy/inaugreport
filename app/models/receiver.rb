# ActionMailer receiver for reports submitted via email
class Receiver < ActionMailer::Base
  def receive(email)
    source_ip = email['Received'].last.comments.first[/\[([\d\.]+)\]/,1] rescue nil
    user_info = { 'uniqueid' => email.from.first,
                  'screen_name' => email.from.first,
                  'name' => email.friendly_from,
                  'profile_location' => source_ip }
    reporter = EmailReporter.update_or_create(user_info)
    puts "email from #{reporter.name} at #{reporter.profile_location}"
    
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
    report.make_thumbnails if report.respond_to?(:make_thumbnails)
  rescue
    nil
  end
end
