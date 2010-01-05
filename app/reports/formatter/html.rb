module Formatter
  class Html < Ruport::Formatter::HTML
    renders :html, :for => Report::AVAILABLE_REPORTS.map(&:report_template)

    include BaseRuportController::Helpers

    def build_report_header
      output << "<h1>#{options.report_title}</h1>"
      output << "<em>#{t(:start_at)}</em>: #{options.start_at.strftime("%d-%m-%Y")}" if options.start_at
      output << "<em>#{t(:end_at)}</em>: #{options.end_at.strftime("%d-%m-%Y")}"     if options.end_at
      output << "<hr />"
    end

    def build_report_body
      if not data.blank?
        data.each_pair do |k,v|
          output << <<HTML
    <div class="report-section">
      <h2>#{t(k)}</h2>
      #{v.to_html(:show_table_headers => true)}
    </div>
HTML
        end
      else
        output << "<div class=\"no-orders\">#{t(:no_orders)}</div>"
      end
    end

    def build_report_summary
      if options.summary
        output << <<HTML
      <div class="report-summary">
        <h2>#{t(:summary)}</h2>
        #{options.summary.to_html(:show_table_headers => true)}
      </div>
HTML
      end
    end

    def build_report_footer
      output << "<hr />"
      output << "<div class=\"report-footer\"><em>#{t(:generated_on)}</em>: #{now}</div>"
    end
  end
end