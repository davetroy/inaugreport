require 'test_helper'

class ReceiverTest < ActionMailer::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures/receiver'

  test "multipart report is received properly" do
    email_text = File.read("#{FIXTURES_PATH}/taylor_swift")
    assert_match /Taylor-Swift/, email_text
    Receiver.receive(email_text)
    reports = Report.find(:all)
    assert_equal 3, reports.size
  end

  test "single part report is received properly" do
    email_text = File.read("#{FIXTURES_PATH}/single_part_email")
    Receiver.receive(email_text)
    reports = Report.find(:all)
    assert_equal 1, reports.size
    assert_match /single part email/, reports.first.body
  end
end
