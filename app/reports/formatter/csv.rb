module Formatter
  class Csv < Ruport::Formatter::CSV
    renders :csv, :for => Report::AVAILABLE_REPORTS.map(&:report_template)

    def build_report_header
      output.replace("")
    end

    def build_report_body
      if data
        result = data.values.first
        output << result.to_html(:show_table_headers => true)
      else
        output << I18n.t(:no_orders, :scope => :report)
      end
    end

    def build_report_summary

    end

    def build_report_footer
      
    end
  end
end
