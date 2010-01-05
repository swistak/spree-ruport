class Admin::ReportsController < Admin::BaseController
  skip_before_filter :verify_authenticity_token

  resource_controller :only => [:index, :destroy]

  def collection
    @report = Report.new
    @report.start_at = Time.zone.now.beginning_of_month
    @report.end_at   = Time.zone.now.end_of_month - 1.day

    @search = Report.searchlogic(params[:search])
    @reports = @collection = @search.paginate(
      :per_page => Spree::Config[:per_page],
      :page     => params[:page]
    )
  end

  def new
    load_object
    save_report if request.post? && params["save"]
    render_preview
  end
  
  def show
    load_object
    before :show
    render_report(params[:format])
  end

  def edit
    @report = Report.find_by_param!(params[:id])
    save_report if request.post?
    render_preview
  end

  destroy.success.wants.js { render_js_for_destroy }

  def options
    @report = Report.new({
        :report_type => params[:report_type],
        :report_title => I18n.t(params[:report_type]),
      })
    render :inline => '<% fields_for :report do |f| %><%= preference_fields(@report, f) %><% end %>'
  end

  protected

  def object
    @object = Report.find_by_param(params[:id]) || Report.new(params[:report])
  end

  def save_report
    if @report.update_attributes(params[:report])
      flash[:notice] = t(:report_saved)
      redirect_to collection_url
    else
      flash[:error] = t(:invalid_report)
    end
  end

  def render_report(format=nil)
    format ||= 'html'
    unless @report.valid?
      flash[:error] = t(:invalid_report)
      redirect_to :action => :index
      return
    end

    rendered_report = @report.render(format)

    case format
    when 'pdf'
      send_data(rendered_report,
        :type => "application/pdf",
        :filename => "#{@report.file_name}.pdf"
      )
    when 'csv'
      send_data(rendered_report,
        :type => "text/csv",
        :filename => "#{@report.file_name}.csv"
      )
    else
      @rendered_report = rendered_report
    end
  end

  def render_preview
    @report.limit = 25
    @report_preview = @report.render('html')
  end

  private
  before_filter :add_styles
  def add_styles
    if request.format == "html"
      render_to_string :inline => "<%= content_for(:head, stylesheet_link_tag('reports')) %>"
      render_to_string :partial => 'admin/reports/sub_menu'
    end
  end

end
