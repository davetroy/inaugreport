module Geo
  class Yahoo < Geocoder
  
    def self.geocode(text)

      # appid is for twittervotereport.com
      # street, city, state, zip, location
      params = { :appid => "7zB1A8vV34HtY3rO5riLV8pY_P.I6CvzsgjLF8uBJvfu70W8CMRaesjRadNDE9rImA--",
                 :output => 'xml',
                 :location => text }
                 
      pstring = params.map { |k,v| "#{k}=#{URI.encode(v)}" }.join('&')
      url = "http://api.local.yahoo.com/MapsService/V1/geocode?#{pstring}"
      loc = ExtractableHash.new.merge(Hash.from_xml(open(url).read))
      
      point = Point.from_x_y(loc.extract('ResultSet Result Longitude').to_f, loc.extract('ResultSet Result Latitude').to_f)
      loc = loc.transform( :thoroughfare => 'ResultSet Result Address',
        :country_code => 'ResultSet Result Country',
        :administrative_area => 'ResultSet Result State',
        :locality => 'ResultSet Result City',
        :postal_code => 'ResultSet Result Zip')
      loc[:address] = "#{loc[:thoroughfare]}, #{loc[:locality]}, #{loc[:postal_code]} #{loc[:country_code]}"
      loc.merge(:point => point, :geo_source_id => 2)
      
    rescue
      nil
    end

  end
end

# {"ResultSet"=>{"xsi:schemaLocation"=>"urn:yahoo:maps http://api.local.yahoo.com/MapsService/V1/GeocodeResponse.xsd", "Result"=>{"City"=>"Arnold", "Zip"=>"21012", 
#   "Country"=>"US", "Longitude"=>"-76.496680", "Latitude"=>"39.046888", "State"=>"MD", "precision"=>"zip", "Address"=>nil},
#   "xmlns:xsi"=>"http://www.w3.org/2001/XMLSchema-instance", "xmlns"=>"urn:yahoo:maps"}}

# create_table "locations", :options=>'ENGINE=MyISAM', :force => true do |t|
#   t.column "address", :string
#   t.column "country_code", :string, :limit => 10
#   t.column "administrative_area", :string, :limit => 80
#   t.column "sub_administrative_area", :string, :limit => 80
#   t.column "locality", :string, :limit => 80
#   t.column "dependent_locality", :string, :limit => 80
#   t.column "thoroughfare", :string, :limit => 80
#   t.column "postal_code", :string, :limit => 25
#   t.column "point", :point, :null => false
#   t.column "geo_source_id", :integer
#   t.column "created_at", :datetime
#   t.column "updated_at", :datetime
# end
