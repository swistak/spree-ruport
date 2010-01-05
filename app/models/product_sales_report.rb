class ProductSalesReport < Report
  preference :sort_by, :string, :default => 'SKU', :values => ['SKU', 'Name']
end
