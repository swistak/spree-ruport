class Admin::MonthlyReportsController < Admin::BaseController
  resource_controller :only => :index
  helper 'admin/reports'

  protected
  def collection
    @report = Report.new

    @monthly_reports = Report.get_monthly_reports
  end

  private
  before_filter :add_styles
  def add_styles
    render_to_string :inline => "<%= content_for(:head, stylesheet_link_tag('reports')) %>"
    render_to_string :partial => 'admin/reports/sub_menu'
  end
end