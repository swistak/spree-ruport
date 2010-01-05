module Formatter
  class Pdf < Ruport::Formatter
    renders :pdf, :for => Report::AVAILABLE_REPORTS.map(&:report_template)

    include BaseRuportController::Helpers

    FONT = "#{Prawn::BASEDIR}/data/fonts/DejaVuSans.ttf"

    def build_report_header
      font FONT
      font_size 10

      image_path = File.join(RAILS_ROOT, 'public', Spree::Config[:pdf_logo] || Spree::Config[:logo])

      start_at = options.start_at.blank? ? ' - ' : options.start_at.strftime('%d-%m-%Y')
      end_at   = options.end_at.blank? ? ' - '   : options.end_at.strftime('%d-%m-%Y')

      pdf.image image_path, {
        :at => [0, pdf.bounds.absolute_top()-10],
        #:height => 50
      }
      pdf.bounding_box([200, pdf.bounds.absolute_top()-10], :width => 300) do
        pdf.text "<i>#{options.report_title}</i>", :align => :right
        pdf.text "%15s: %s" % [t(:start_at), start_at], :align => :right
        pdf.text "%15s: %s" % [t(:end_at), end_at], :align => :right
        pdf.move_down(5)
      end

      pdf.move_down(5)
      pdf.pad(10){ hr }
    end

    def build_report_body
      if data
        data.each_pair do |name, values|
          new_section(100)
          pdf.pad(10){ pdf.text t(name), :size => 16  }
          
          pdf.pad_bottom(15) do
            case values
            when Ruport::Data::Table
              draw_table(values, {
                  :width => 525,
                  :font_size => 8,
                })
            when Ruport::Data::Grouping
              values.each do |name, group|
                pad(10) { add_text name.to_s, :justification => :center }
                draw_table(group, {
                    :width => 525,
                    :font_size => 8,
                  })
              end
            end
            
          end
          new_page_if_needed
        end
      else
        pdf.pad(10){ pdf.text "<i>#{t(:no_orders)}</i>", :size => 12 }
      end
    end

    def build_report_summary
      if options.summary
        new_section(100)

        pdf.pad(10) do
          draw_table options.summary,
            :position => 230,
            :width => 300,
            :column_widths => {
            0 => 200,
            1 => 100,
          }
        end
      end
    end

    def build_report_footer
      pdf.pad(10) { hr }
      pdf.text "<i>#{options.report_type.constantize.human_name}</i> #{t(:generated_at)}: <b>#{now}</b>", :align => :center, :size => 8
    end

    def finalize
      output << pdf.render
    end

    ############ Default renderers for common ruport data structures ###########

    renders :pdf, :for => [ Ruport::Controller::Row, Ruport::Controller::Table,
      Ruport::Controller::Group, Ruport::Controller::Grouping ]

    ############ HELPER METHODS ################

    def document
      @document ||= (options.document || Prawn::Document.new)
    end

    alias pdf document
    alias pdf_writer document

    def table_body
      data.map { |e| e.to_a }
    end

    def hr
      document.stroke_horizontal_rule
    end

    def draw_table(data, opts={})
      headers = options.headers || data.column_names
      table_body = data.map { |e| e.to_a }
      pdf.table table_body, {
        :headers => headers,
        :row_colors => :pdf_writer,
        :position => :center,
        :font_size => 10,
        :vertical_padding => 2,
        :horizontal_padding => 5
      }.merge(opts)
    end

    def add_text(text, format_opts={})
      document.text(text, format_opts)
    end

    def new_section(spacer = 60)
      new_page_if_needed(spacer) { pdf.pad(5) { hr } }
    end

    def new_page_if_needed(spacer = 60, &block)
      if pdf.y < pdf.bounds.absolute_bottom() + spacer
        pdf.start_new_page
      elsif block
        block.call()
      end
    end

    def method_missing(name, *args, &block)
      if pdf.respond_to?(name)
        $stderr.puts("Missing method #{name} called on pdf with #{args.inspect}")
        pdf.send(name, *args, &block)
      else
        $stderr.puts("Missing method #{name} called with #{args.inspect}")
        super
      end
    end
  end
end