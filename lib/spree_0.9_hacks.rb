##### CORE OVERRIDES ############
Spree::Preferences::PreferenceDefinition.module_eval do
  def initialize(attribute, *args) #:nodoc:
    options = args.extract_options!
    options.assert_valid_keys(:default, :values)

    @type = args.first ? args.first.to_s : 'boolean'
    @values = options[:values]

    # Create a column that will be responsible for typecasting
    @column = ActiveRecord::ConnectionAdapters::Column.new(attribute.to_s, options[:default], @type == 'any' ? nil : @type)
  end

  # List of possible values that can be set for the preference.
  def values
    @values
  end
end

Admin::BaseHelper.module_eval do
  def preference_field(form, field, options)
    case options[:type]
    when :integer
      form.text_field(field, {
          :size => 10,
          :class => 'input_integer',
          :readonly => options[:readonly],
          :disabled => options[:disabled]
        }
      )
    when :boolean
      form.check_box(field, {:readonly => options[:readonly],
          :disabled => options[:disabled]})
    when :string
      if options.key? :values
        form.select(field, options[:values], {
            :size => 10,
            :class => 'input_string',
            :readonly => options[:readonly],
            :disabled => options[:disabled]
          })
      else
        form.text_field(field, {
            :size => 10,
            :class => 'input_string',
            :readonly => options[:readonly],
            :disabled => options[:disabled]
          }
        )
      end
    when :password
      form.password_field(field, {
          :size => 10,
          :class => 'password_string',
          :readonly => options[:readonly],
          :disabled => options[:disabled]
        }
      )
    when :text
      form.text_area(field,
        {:rows => 15, :cols => 85, :readonly => options[:readonly],
          :disabled => options[:disabled]}
      )
    else
      form.text_field(field, {
          :size => 10,
          :class => 'input_string',
          :readonly => options[:readonly],
          :disabled => options[:disabled]
        }
      )
    end
  end

  def preference_fields(object, form)
    return unless object.respond_to?(:preferences)
    object.preferences.keys.map{ |key|
      next unless object.class.preference_definitions.has_key? key

      definition = object.class.preference_definitions[key]
      type = definition.instance_eval{@type}.to_sym
      values = definition.values

      form.label("preferred_#{key}", t(key)+": ") +
        preference_field(form, "preferred_#{key}", {:type => type, :values => values})
    }.join("<br />")
  end
end


# XXX: This is ugly ugly ugly hack to get prawn working. It should be removed
# as soon as I know how to fix it, see http://github.com/sandal/prawn/issues/#issue/73
Prawn::Format.module_eval do
  # Overloaded version of #height_of.
  def height_of(string, line_width, size=font_size, options={}) #:nodoc:
    if unformatted?(string, options)
      super(string, :size => size)
      #super(string, line_width, size)
    else
      formatted_height(string, line_width, size, options)
    end
  end
end