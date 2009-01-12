class TwitterReporter < Reporter
  before_save :set_location
  EXTRACTOR = Regexp.new(/^(\w+?):\s(.*)$/m)

  attr_accessor :url, :description, :protected
  
  def source_name; "Twitter"; end
  def source; "Twitter"; end
  def icon; profile_image_url; end
  
  def profile
    "http://twitter.com/#{screen_name}"
  end


  def self.fetch_archive
    ta = Twitterchive.new(APP_TAG, :fields => ["google:location"], :search => {:geocode => "38.892091%2C-77.024055%2C50mi"}, :paginate => true)
    ta.fetch
    ta.entries.collect do |entry|
      user_info = {'uniqueid' => entry['author/uri'].gsub(/http:\/\/twitter\.com\//,''), 'location' => entry['google:location']}

      next unless reporter = TwitterReporter.update_or_create(user_info)

      reporter.reports.create(:body => entry['title'],
                          :uniqueid => entry['id'],
                          :created_at => entry['published'],
                          :location => Location.geocode(entry['google:location']))
    end    
  end
  
  private
  def set_location
    if location_id.nil? || (self.profile_location!=attributes['profile_location'])
      self.location = Location.geocode(attributes['profile_location'])
    end
  end  
end
