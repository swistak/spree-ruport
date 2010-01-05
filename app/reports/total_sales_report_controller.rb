class TotalSalesReportController < BaseRuportController
  include ActionView::Helpers::NumberHelper

  def prepare_table
    Order.report_table(:all, {
        :only => ['total', 'item_total'],
        :methods => ['credit_total', 'charge_total', 'tax_total', 'ship_total'],
        :conditions => conditions(options),
        :limit => options.limit,
    })
  end

  def setup
    table = prepare_table

    if table.size > 0
      totals = Table(%w[total item_total ship_total tax_total charge_total credit_total])

      totals << {
        "total"       => number_to_currency(table.sigma("total")),
        "item_total"  => number_to_currency(table.sigma("item_total")),
        "ship_total"  => number_to_currency(table.sigma("ship_total")),
        "tax_total"   => number_to_currency(table.sigma("tax_total")),
        "charge_total"=> number_to_currency(table.sigma("charge_total")),
        "credit_total"=> number_to_currency(table.sigma("credit_total"))
      }
      totals.rename_columns { |c| t(c) }
      self.data = {:totals => totals}
    else
      self.data = {}
    end
  end
end
