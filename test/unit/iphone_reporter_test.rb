require File.dirname(__FILE__) + '/../test_helper'

class IphoneReporterTest < ActiveSupport::TestCase
  def test_iphone_reporter_creation
    reporter = IphoneReporter.create("uniqueid"=>"E8F8D731-648C-5A07-81D8-5C4BA6CDFE45", "zipcode"=>"20171", "firstname"=>"Sze", "lastname"=>"Wong", "email"=>"swong@zerionconsulting.com")
    assert_equal '20171', reporter.profile_location
    assert_nil reporter.followers_count
    assert_equal "Sze Wong", reporter.name
    assert_equal "swong@zerionconsulting.com", reporter.screen_name
    assert_match /iPhone App$/, reporter.source_name
    assert_equal "E8F8D731-648C-5A07-81D8-5C4BA6CDFE45", reporter.uniqueid
    text_report = reporter.text_reports.create("latlon"=>"37.332,-122.031:100", "body"=>"Text again", "title"=>"Test text again")
    assert_equal 100, text_report.location_accuracy
    assert_equal 37.332, text_report.location.latitude
    assert_equal -122.031, text_report.location.longitude
    #p text_report.location
  end
end

# report = reporter.reports.create(:text => 'all is well in l:New York', :score => '62', :tag_string => '#machine #registration', :latlon => '39.024,-76.511:2192',
#                                   :polling_place => PollingPlace.create(:name => 'Elem School') )
# assert_equal 1, reporter.reports.size
# assert_equal "New York, NY, USA", report.location.address
# assert_equal 62, report.score
# assert_equal 2, report.tags.size
# assert_equal 2192, report.location_accuracy.to_i
# assert report.uniqueid.ends_with?(report.id)
