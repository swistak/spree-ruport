class ChangeReportName < ActiveRecord::Migration
  def self.up
    Report.update_all({:report_type => 'DetailedOrdersReport'}, {:report_type => 'DetailedSalesReport'})
  end

  def self.down
  end
end