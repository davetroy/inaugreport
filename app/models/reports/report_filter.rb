# Join model to link reports to location filters
class ReportFilter < ActiveRecord::Base
  belongs_to :report
	belongs_to :filter
end
