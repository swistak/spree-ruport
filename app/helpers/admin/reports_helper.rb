module Admin
  module ReportsHelper
    def link_to_report(report, overrides={})
      label = overrides.delete(:label) || report.name
      action = overrides.delete(:action) || :show

      options = report.attributes.symbolize_keys.merge(overrides.symbolize_keys)

      options = {
        :action => action,
        :id => report.permalink.blank? ? report.file_name : report.permalink,
        :format => options[:format],
        :report => options
      }

      link_to label, options
    end

    def links_to_report(report, overrides={})
      Report::AVAILABLE_FORMATS.map{|f|
        link_to_report(report, overrides.merge(:label => f, :format => f))
      }.join(" | ")
    end
  end
end
