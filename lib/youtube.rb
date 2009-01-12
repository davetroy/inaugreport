# Simple youtube wrapper
# (C) 2007-2009 David Troy, dave@roundhousetech.com

module Youtube
  def find_tag(tag)
    params = {'vq' => tag, 'orderby' => 'updated', 'max-results' => '50'}
    pstring = params.map { |k,v| "#{k}=#{URI.encode(v)}" }.join('&')
    url = "http://gdata.youtube.com/feeds/api/videos?#{pstring}"
    doc = get_and_parse_xml_safely(url)
    p url
    p doc
    return false unless doc && doc['feed'] && doc['feed']['entry'] && doc['feed']['entry'].any?
  end
  
  
  def get_and_parse_xml_safely(url)
    retries = 0
    begin
      response = open(url).read
      doc = Hash.from_xml(response)
    rescue Timeout::Error => e
      retries += 1
      retry if retries < 4
    rescue
      retries += 1
      retry if retries < 4
    end
    doc
  end

end
