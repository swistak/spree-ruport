class DetailedOrdersReportController < BaseRuportController
  def prepare_line_items_table
    LineItem.report_table(:all, {
        :only => ['quantity'],
        :methods => ['total'],
        :include => {
          :variant => {
            :only => 'sku',
            :methods => ['display_name'],
            :include => {
              :product => {:only => {}}
            }
          },
          :order => {
            :only => ['number'],
          }
        },

        :filters => nil,
        :transforms => nil,
        :conditions => conditions(options),
        :limit => options.limit,
        :order => "orders.completed_at ASC"
      })
  end

  def prepare_summary_table(table)
    summary_table_data = ['total'].map{|c|
      [t(c), "%.2f" % table.sigma(c)]
    }

    Table(['summary', 'value'], :data => summary_table_data)
  end

  def setup
    line_items_table = prepare_line_items_table
    if line_items_table.size > 0
      summary_table    = prepare_summary_table(line_items_table)
      line_items_table.reorder('variant.sku', 'variant.display_name', 'quantity', 'total', 'order.number')

      line_items_table.replace_column('total') { |r| "%.2f" % r.total }

      line_items_table.rename_column("variant.sku", "variant SKU")
      line_items_table.rename_column("order.number", "order number")
      line_items_table.rename_columns { |c| t(c) }
      summary_table.rename_columns{|c| t(c)}

      grouping = Grouping(line_items_table, :by => I18n.t("order number"), :order => lambda{|o| Order.find_by_number(o.name).completed_at})
      grouping.each do |name,group|
        group << ['','',I18n.t("order_total"), group.sigma(t('total'))]
      end
      self.data = {:orders => grouping}
      options.summary = summary_table
    end
  end
end
