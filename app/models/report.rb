# h2. Description
#
# *Report* class is an abstract class providing common functionality for all
# children classes that represent concrete types of reports.
#
# h2. Custom reports
#
# When creating new reports you have to provide two classes:
# * Model (in app/models)
# * Ruport Controller (in app/reports)
#
# Model should inherit from _Report_ and provide preferences needed to generate
# the report. Controller should be named exactly like model, but with Controller
# suffix and inherit from _BaseRuportController_
#
# In your extension #activate method you also need to activate report by adding it to
# Report::AVAILABLE_REPORTS set.
#
#   Report::AVAILABLE_REPORTS.add(MyCustomReport)
#
class Report < ActiveRecord::Base
  # string :report_type
  # string :comment
  # string :report_title
  #
  # timestamp :start_at
  # timestamp :end_at

  self.inheritance_column = 'report_type'

  make_permalink

  AVAILABLE_REPORTS = Set.new([
      TotalSalesReport,
      ProductSalesReport,
      DetailedOrdersReport,
    ])

  REPORT_PATH = File.join(RAILS_ROOT, "public", "saved_reports", "")
  REPORTABLE_STATES = ["paid", "shipped"]
  AVAILABLE_FORMATS = ['html', 'pdf', 'csv']

  attr_accessor :format
  attr_accessor :limit
  validates_presence_of  :report_title

  class << self
    # This methods allows for easy creation of proper STI class using :type attribute
    def new_with_cast(attributes=nil)
      attributes &&= attributes.stringify_keys
      if attributes && attributes[self.inheritance_column] && attributes[self.inheritance_column] != self.name
        subclass = attributes.delete(self.inheritance_column).constantize
        raise TypeError, "#{attributes[self.inheritance_column]} is not subclass of #{self.name}" unless subclass < self
        subclass.new_without_cast(attributes)
      else
        self.new_without_cast(attributes)
      end
    end
    alias_method_chain :new, :cast

    # returns class of report template
    def report_template
      @report_template ||= "#{self.name}Controller".constantize
    end
    alias report_controller report_template

    # Generate set of ad-hoc reports for each available report and for
    # each month since the first order entered reportable state.
    def get_monthly_reports(options={})
      monthly_reports = []

      months_back = 0
      start_time = Time.zone.now

      # Generate monthly reports going back in time till thee are no more orders
      while Order.count(:conditions => ['orders.completed_at < ?', start_time]) > 0
        time = Time.zone.now.at_beginning_of_month - months_back.months
        start_time = time.at_beginning_of_month
        end_time = time.at_end_of_month

        reports = AVAILABLE_REPORTS.map do |report_klass|
          report_klass.new({
              :start_at => start_time.to_date.to_s,
              :end_at => end_time.to_date.to_s,
            }.merge(options.symbolize_keys))
        end
        monthly_reports << {
          :start_at => start_time.to_date,
          :end_at   => end_time.to_date,
          :reports  => reports
        }
        months_back += 1
      end
      return(monthly_reports)
    end
  end
  
  # Renders report in a choosen format.
  #
  # format can be passed as parameter, if it's left nil, default format from report is choosen.
  # optional second argument timeout(in seonds) can be passed to limit time allowed for
  # generation of the report (defaults to 3 minutes).
  def render(format = nil, timeout = 180)
    format ||= AVAILABLE_FORMATS.first
    Timeout.timeout(timeout) do
      self.class.report_template.render(format.to_sym, report_options)
    end
  end

  # Generate the default file name for report (without extension)
  # based on time and name of the report.
  def file_name
    "#{name.to_url}_#{(updated_at || Time.now).strftime("%Y-%m-%d")}"
  end

  # Generates the default name for the report using title or translated report type,
  #  and comment.
  def name
    report_title.blank? ? self.class.human_name : report_title
  end

  # Retrives all orders that fullfill report conditions.
  # Used for debuging.
  def orders
    unless report_type.blank?
      conditions = report_template.conditions.call(OpenStruct.new(report_options))
      Order.find(:all, :conditions => conditions)
    end
  end

  def report_options
    self.attributes.merge(self.preferences).merge({:limit => limit})
  end

  # Making sure preferences method is always available
  def preferences; {}; end

  alias to_s name
  alias to_param file_name
end
