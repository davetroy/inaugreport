xml.feed "xmlns" => "http://www.w3.org/2005/Atom", 
"xmlns:georss" => "http://www.georss.org/georss",
"xmlns:opensearch" => "http://a9.com/-/spec/opensearch/1.1/" do

  xml.title "##{APP_TAG}"
  xml.id reports_path(:only_path => false)
  xml.link    :rel => "self", :type => "application/atom+xml", :href => formatted_reports_path(:format => 'atom', :only_path => false )
  xml.link    :rel => "alternate", :type => "application/vnd.google-earth.kml+xml", :href => formatted_reports_path(:only_path => false, :format => 'kml')
  xml.link    :rel => "alternate", :type => "text/html", :href => reports_path(:only_path => false)
  xml.opensearch(:totalResults, @reports.total_entries)
  xml.opensearch(:startIndex, @reports.current_page * @reports.per_page)
  xml.opensearch(:itemsPerPage, @reports.per_page)  
  xml.updated Time.now.iso8601
  xml.link(:rel => "first", :href => url_for(params.merge(:page => 1, :only_path => false)), :type => "application/atom+xml")    
  xml.link(:rel => "previous", :href => url_for(params.merge(:page => @reports.previous_page, :only_path => false)), :type => "application/atom+xml") unless @reports.previous_page.nil?
  xml.link(:rel => "next", :href => url_for(params.merge(:page => @reports.next_page, :only_path => false)), :type => "application/atom+xml") unless @reports.next_page.nil?
  xml.link(:rel => "last", :href => url_for(params.merge(:page => @reports.total_pages, :only_path => false)), :type => "application/atom+xml")    

  @reports.each_with_index do |report, count|
    xml.entry do
      xml.title   report.reporter.name if report.reporter.name
      xml.link    :rel => "alternate", :href => report_url( report ), :type => "text/html"
      xml.id      url_for(:only_path => false, :controller => :reports, :action => :show, :id => report.id)
      xml.updated report.updated_at.strftime("%Y-%m-%dT%H:%M:%SZ") unless report.updated_at.nil?
      xml.author  { xml.name report.reporter.name }
      xml.summary report.body unless report.body.nil?
      %w{score type}.each do |attribute|
        xml.tag! "category", :term => "#{attribute}=#{report.send(attribute.to_sym)}"
      end
      xml << report.location.point.as_georss unless report.location.nil?
      xml.content :type => "html" do
        xml.text! CGI::unescapeHTML(%Q{<div id="#{ dom_id(report) }" class="balloon">
  #{ if report.reporter.class == TwitterReporter
    link_to( image_tag(report.icon, :class => "profile", :target=>"new"), report.reporter.profile)
   else 
     image_tag(report.icon, :class => "profile")
   end }
  <span class="vcard author" id="screen_name">#{report.reporter.name}</span>: <span class="entry-title">#{report.display_text}</span> 
  <span class="whenwhere">
  #{ if report.reporter.class == TwitterReporter
    link_to(time_ago_in_words(report.created_at) + " ago", "http://twitter.com/" + (report.reporter.screen_name || "") + "/statuses/" + report.uniqueid || "")
   else
    '<abbr class="published" title="#{ report.created_at.iso8601 }">#{time_ago_in_words(report.created_at)}</abbr> ago'
   end }    
    #{"in <span class=\"adr\">#{report.location.address}</span>" if report.location}
    via #{report.reporter.source_name}<br/>
    #{report.media_link}
  </span>
</div>}) unless report.body.blank?
      end 
    end
  end

end
