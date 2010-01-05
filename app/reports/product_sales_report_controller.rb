class ProductSalesReportController < BaseRuportController
  include ActionView::Helpers::NumberHelper
  
  def prepare_line_items_table
    LineItem.report_table(:all, {
        :only => ['quantity'],
        :methods => ['total'],
        :include => {
          :variant => {
            :only => 'sku',
            :methods => ['display_name']
          },
          :order => {
            :only => ['completed_at']
          }
        },
        :conditions => conditions(options),
        :limit => options.limit,
      })
  end

  def setup
    line_items_table = prepare_line_items_table
    if line_items_table.size > 0
      grouping = Grouping(line_items_table, :by => "variant.display_name")

      products = Table(%w[sku name total count])

      grouping.each do |name,group|
        products << { "sku"   => group.data.first.data["variant.sku"],
                      "name"  => name,
                      "total" => group.sigma("total"),
                      "count" => group.sigma("quantity") }
      end

      products.sort_rows_by!(options.sort_by.downcase, :order => :descending) if options.sort_by
      products.replace_column('total') { |r| number_to_currency(r.total) }
      products.rename_columns { |c| t(c) }

      products = products.to_group
      self.data = {:products => products}
    else
      self.data = {}
    end
  end
end
