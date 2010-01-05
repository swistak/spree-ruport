Order.acts_as_reportable({
    :only => ['number']
  })
LineItem.acts_as_reportable({
    :include => :variant,
    :only => ['quantity', 'price']
  })
Variant.acts_as_reportable({
    :only => 'sku',
    :include => :product
  })
Product.acts_as_reportable({
    :only => 'name'
  })
Checkout.acts_as_reportable({
    :only => ['completed_at']
  })
Adjustment.acts_as_reportable({
    :only => ['total']
  })

Variant.class_eval do
  def options_text
    self.option_values.map { |ov| ov.presentation }.to_sentence({:words_connector => ", ", :two_words_connector => ", "})
  end

  def display_name
    "#{product.name}" + (option_values.empty? ? '' : "(#{options_text})")
  end
end