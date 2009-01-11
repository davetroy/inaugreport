class Report < ActiveRecord::Base
	
  validates_presence_of :reporter_id
  validates_uniqueness_of :uniqueid, :scope => :type, :allow_blank => true, :message => 'already processed'
  
  attr_accessor :latlon   # virtual field supplied by iphone/android
  
  belongs_to :location
  belongs_to :reporter
  belongs_to :reviewer, :class_name => "User"
  
  has_many :report_tags, :dependent => :destroy
  has_many :tags, :through => :report_tags
  has_many :report_filters, :dependent => :destroy
  has_many :filters, :through => :report_filters

  before_create :detect_location
  # check_uniqueid must be AFTER create because otherwise it doesn't have an ID
  after_create :check_uniqueid, :assign_filters, :auto_review
  
  named_scope :with_location, :conditions => 'location_id IS NOT NULL'
  named_scope :with_rating, :conditions => 'rating IS NOT NULL'
  named_scope :assigned, lambda { |user| 
    { :conditions => ['reviewer_id = ? AND reviewed_at IS NULL AND assigned_at > UTC_TIMESTAMP - INTERVAL 10 MINUTE', user.id],
      :order => 'created_at DESC' }
  }
  # @reports = Report.unassigned.assign(@current_user) &tc...
  named_scope( :unassigned, 
    :limit => 10, 
    :order => 'created_at DESC',
    :conditions => 'reviewed_at IS NULL AND (reviewer_id IS NULL OR assigned_at < UTC_TIMESTAMP - INTERVAL 10 MINUTE)' 
  ) do
    def assign(reviewer)
      # FIXME: can't we do this more efficiently? a la p-code:
      # self.update_all(reviewer_id=reviewer.id, assigned_at => time.now where id IN (each.collect{r.id}))
      each { |r| r.update_attributes(:reviewer_id => reviewer.id, :assigned_at => Time.now.utc) }
    end
  end

  cattr_accessor :public_fields
  @@public_fields = [:id,:body,:score,:created_at,:updated_at]

  def name
    self.reporter.name
  end
  
  def dismiss!(user=nil)
    self.dismissed_at = Time.now.utc
    self.reviewer = user if user
    self.reviewed_at = Time.now.utc
    user.update_reports_count! if user
    self.save_with_validation(false)
  end
  
  def confirm!(user=nil)
    self.dismissed_at = nil
    self.reviewer = user if user
    self.reviewed_at = Time.now.utc
    if self.save
      user.update_reports_count! if user
      return true
    else
      return false
    end
  end
  
  def is_confirmed?
    self.dismissed_at.nil? && !self.reviewed_at.nil?
  end
  
  def is_dismissed?
    !self.dismissed_at.nil?
  end
  
  def icon
    self.reporter.icon =~ /http:/ ? self.reporter.icon : "#{SERVER_URL}#{self.reporter.icon}"
  end
    
  alias_method :ar_to_json, :to_json
  def to_json(options = {})
    options[:only] = @@public_fields
    # options[:include] = [ :reporter ]
    # options[:except] = [ ]
    options[:methods] = [ :audio_link, :display_text, :display_html, :rating, :name, :icon, :reporter, :location ].concat(options[:methods]||[]) #lets us include current_items from feeds_controller#show
    # options[:additional] = {:page => options[:page] }
    ar_to_json(options)
  end    

  def audio_link
    "#{self.reporter.audio_path}/#{self.audio_file}" if self.has_audio
  end
  
  def self.find_with_filters(filters = {})
    conditions = ["",filters]
    if filters.include?(:dtstart) && !filters[:dtstart].blank?
      conditions[0] << "created_at >= :dtstart"
    end
    if filters.include?(:dtend) && !filters[:dtend].blank?
      conditions[0] << "created_at <= :dtend"
    end
    if filters.include?(:rating) && !filters[:rating].blank?
      conditions[0] << "rating IS NOT NULL AND rating <= :rating"
    end
    if filters.include?(:q) && !filters[:q].blank?
      conditions[0] << "body LIKE :q"
      filters[:q] = "%#{filters[:q]}%"
    end
    
    if filters.include?(:state) && !filters[:state].blank?
      filtered = Filter.find_by_name(US_STATES[filters[:state]])
      filtered.reports.paginate( :page => filters[:page] || 1, :per_page => filters[:per_page] || 10, 
                        :order => 'created_at DESC') if filtered
    elsif filters.include?(:name) && !filters[:name].blank?
      reporter = Reporter.find_by_screen_name(filters[:name])
      reporter.reports.paginate( :page => filters[:page] || 1, :per_page => filters[:per_page] || 10, 
                        :order => 'created_at DESC') if reporter
    else
      # TODO put in logic here for doing filtering by appropriate parameters
      Report.paginate( :page => filters[:page] || 1, :per_page => filters[:per_page] || 10, 
                        :order => 'created_at DESC',
                        :conditions => conditions,
                        :include => [:location, :reporter])
    end
  end
      
  # Subsititute text for reports that have none
  def display_text
    return self.body unless self.body.blank?
    [rating        ? "rating #{rating}" : nil ].compact.join(', ')    
  end
  

  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::TagHelper
  def display_html
    html = '<div class="balloon">'

    if self.reporter.class == TwitterReporter
      html << %Q{<a href="#{self.reporter.profile}"><img src=#{self.reporter.icon} class="profile" target="_new"/></a>}
    else
      html << %Q{<br /><img src="#{self.reporter.icon}" class="profile" />}
    end
    if(self.rating.nil?)
      rating_icon = "/images/rating_none.png"
    elsif(self.rating <= 30)
      rating_icon = "/images/rating_bad.png"
    elsif (self.rating <= 70)
      rating_icon = "/images/rating_medium.png"
    else
      rating_icon = "/images/rating_good.png"
    end
    
    html << %Q{<img class="rating_icon" style="clear:left;" src="#{rating_icon}" />}
    html << %Q{<div class="balloon_body"><span class="author" id="screen_name">#{self.reporter.name}</span>: }
    linked_text = auto_link_urls(self.body, :target => '_new') { |linktext| truncate(linktext, 30) }
    html << %Q{<span class="entry-title">#{linked_text}</span><br />}
    html << [rating        ? "Rating: #{rating}" : nil ].compact.join('<br />')    

    html << "<br /><div class='whenwhere'>"
    if self.reporter.class == TwitterReporter
      html << %Q{reported <a href="http://twitter.com/#{self.reporter.screen_name}/statuses/#{self.uniqueid}">#{ time_ago_in_words(self.created_at)} ago</a> }
    else
      html << "reported #{time_ago_in_words(self.created_at)} ago"
    end
    html << "<br />from #{self.location.address.gsub(/, USA/,'')}"
    html << "<br />via #{self.reporter.source_name}</div></div></div>"

    html
  end

  def self.hourly_usage
    ActiveRecord::Base.connection.select_all(%Q{select count(*) as count, HOUR(created_at)-4 as hour from reports WHERE created_at > "2008-11-04" group by HOUR(created_at)})    
  end
  
  private

  # Populate a uniqueid if not supplied by the reporting mechanism
  def check_uniqueid
    update_attribute(:uniqueid, "#{Time.now.to_i}.#{self.id}") if self.uniqueid.nil?
    true
  end
  
  # Detect and geocode any location information present in the report text
  def detect_location
    if self.latlon
      latlon, self.location_accuracy = self.latlon.split(/:/)
      self.location = Location.geocode(latlon)
    elsif self.body
      LOCATION_PATTERNS.find { |p| self.body[p] }
      self.location = Location.geocode($1) if $1
    end
    self.reporter.location = self.location if self.location
    true
  end
    
  # What location filters apply to this report?  US, MD, etc?
  def assign_filters
    if self.location_id && self.location.filter_list
			values = self.location.filter_list.split(',').map { |f| "(#{f},#{self.id})" }.join(',')
      self.connection.execute("INSERT DELAYED INTO report_filters (filter_id,report_id) VALUES #{values}") if !values.blank?
		end
		true
  end
  
  def auto_review
    # TODO: this should approve things that fall within kosher-seeming params
    true
  end
end
