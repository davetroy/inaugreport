require 'test_helper'

class ReceiverTest < ActionMailer::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures/receiver'

  test "report is received properly" do
    email_text = File.read("#{FIXTURES_PATH}/taylor_swift")
    assert_match /Taylor-Swift/, email_text
    Receiver.receive(email_text)
  end

  test "the truth" do
    assert true
  end
end
