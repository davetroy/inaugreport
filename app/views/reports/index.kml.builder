xml.kml("xmlns" => "http://earth.google.com/kml/2.2", 
    "xmlns:atom" => "http://www.w3.org/2005/Atom") do
  xml.tag! "Document" do
    xml.name "##{APP_TAG}"
    xml.description "Voting Reports for the 2008 election"
    xml.tag! "LookAt" do # look at the bounds of the US (approximately)
      xml.longitude -98
      xml.latitude 39
      xml.altitude 8900000
    end    
    xml.tag! "NetworkLink" do
      xml.name "##{APP_TAG} live updating"
      xml.tag! "Link" do
        xml.href cached_count_feed_url(:count => 4000, :format => :kml) #"#{SERVER_URL}/reports/count/4000.kml"
        xml.refreshMode "onInterval"
        xml.refreshInterval 240
        xml.viewRefreshMode "onInterval"
        xml.viewRefreshTime 240
      end
    end
  end
end