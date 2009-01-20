class Reporter < ActiveRecord::Base
  has_many :reports, :dependent => :destroy
  has_many :audio_reports, :dependent => :destroy
  has_many :photo_reports, :dependent => :destroy
  has_many :text_reports, :dependent => :destroy
  has_many :video_reports, :dependent => :destroy
  
  belongs_to :location
  belongs_to :home_location, :class_name => "Location"

  validates_presence_of :uniqueid
  validates_uniqueness_of :uniqueid, :scope => :type, :allow_blank => false
  before_save { |record| record.home_location ||= record.location if record.location }
  
  cattr_accessor :public_fields
  @@public_fields = [:name]
 
  alias_method :ar_to_json, :to_json
  def to_json(options = {})
    options[:only] = @@public_fields
    # options[:include] = [ ]
    # options[:except] = [ ]
    options[:methods] = [ :icon ].concat(options[:methods]||[]) #lets us include current_items from feeds_controller#show
    options[:additional] = {:page => options[:page] }
    # ar_to_json(options)
    (options[:only] + options[:methods]).inject(options[:additional]) {|result,field| result[field] = self.send(field); result }.to_json
  end  

  # Takes a hash of reporter data
  # Adds to database if it's new to us, otherwise finds record and returns it
  def self.update_or_create(fields)
    if reporter = find_by_uniqueid(fields['uniqueid'])
      reporter.update_attributes(fields)
    else
      reporter = create(fields)
    end
    reporter
  end
  
  # Takes hash of reporter and report data from POST (or email)
  # and generates proper objects
  def self.save_report(info)
    reporter = self.update_or_create(info[:reporter])
    if info[:soundfile]
      report = reporter.audio_reports.create(info[:report])
    elsif info[:imagefile]
      report = reporter.photo_reports.create(info[:report])
    else
      report = reporter.text_reports.create(info[:report])
    end
    if uploadedfile = info[:uploaded]
      File.open(report.filename, 'w') { |f| f.write uploadedfile.read }
      report.make_thumbnails
    end
    "OK"
  rescue => e
    logger.info "*** #{self.class} ERROR: #{e.class}: #{e.message}\n\t#{e.backtrace.first}"
    "ERROR"
  end
  
  def blocked?
    false
  end
end
