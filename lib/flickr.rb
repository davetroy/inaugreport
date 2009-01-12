# Simple flickr wrapper
# (C) 2007-2009 David Troy, dave@roundhousetech.com

module Flickr
  def method_missing(method, params={})
    raise NameError unless method.is_a?(Symbol) && params.is_a?(Hash)
    params.merge!(:api_key => '9b02101c75c95e1669d4bf64340a8df7', :format => 'json')
    pstring = params.map { |k,v| "#{k}=#{URI.encode(v)}" }.join('&')
    method = method.to_s.gsub('_', '.')
    return nil unless response = open("http://api.flickr.com/services/rest/?method=flickr.#{method}&#{pstring}").read
    JSON.parse(response[/^jsonFlickrApi\((.*?)\)$/m,1])
  end
end

