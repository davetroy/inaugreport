require File.dirname(__FILE__) + '/../test_helper'

class ReportsControllerTest < ActionController::TestCase
  def test_paginated_index_loads
    get(:index, :format => 'html')
    assert_response :success
    assert !@response.body.include?("hdn_reports_container")
  end
  
  # def test_live_autoupdate_index_loads
  #   get(:index, :live => "1", :format => 'html')
  #   assert_response :success
  #   assert @response.body.include?("hdn_reports_container")
  # end
  # 
  # def test_reload_loads
  #   get(:reload)
  #   assert_response :success
  #   exp_size = [50, Report.count].min
  #   assert_equal exp_size, assigns(:reports).size
  # end
  # 
  # def test_reload_reads_count_param
  #   get(:reload, :per_page => 2)
  #   assert_response :success
  #   assert_equal 2, assigns(:reports).size
  # end
  
  def test_create_iphone_report
    post(:create, "reporter"=>{"uniqueid"=>"13506d733bc5372a3b818fdf29ef8fb7386b3dc3", "zipcode"=>"21012", "firstname"=>"David", "lastname"=>"Troy", "email"=>"dave@popvox.com"},
                "format"=>"iphone",
                "report"=>{"latlon"=>"39.025,-76.511:114", "title"=>"This is a test", "body" => "Body text" } )
    assert_response :success
    assert_equal "OK", @response.body
    reporter = IphoneReporter.find_by_uniqueid("13506d733bc5372a3b818fdf29ef8fb7386b3dc3")
    p reporter
  end
end
