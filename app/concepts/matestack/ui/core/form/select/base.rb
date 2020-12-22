require_relative '../utils'
require_relative '../has_errors'
module Matestack::Ui::Core::Form::Select
  class Base < Matestack::Ui::Core::Component::Dynamic
    include Matestack::Ui::Core::Form::Utils
    include Matestack::Ui::Core::Form::HasErrors

    html_attributes :autofocus, :disabled, :form, :multiple, :name, :required, :size

    requires :key
    optional :multiple, :init, :placeholder, :disabled_values,
      for: { as: :input_for },
      label: { as: :input_label },
      options: { as: :select_options }

    def setup
      @component_config[:init_value] = init_value
    end


    def component_id
      "select-component-for-#{attr_key}"
    end

    def select_attributes
      html_attributes.merge(attributes: vue_attributes)
    end

    def render_options
      if placeholder
        option value: 'null', disabled: true, selected: init_value.nil?, text: placeholder
      end
      select_options.to_a.each do |item|
        option value: item_value(item), disabled: item_disabled(item), text: item_label(item)
      end
    end

    def input_key
      "$parent.data[\"#{key}\"]"
    end

    def error_key
      "$parent.errors[\"#{key}\"]"
    end

    def change_event
      "inputChanged('#{attr_key}')"
    end

    def vue_attributes
      (options[:attributes] || {}).merge({
        "@change": change_event,
        ref: vue_ref,
        'init-value': init_value || [],
        'v-bind:class': "{ '#{input_error_class}': #{error_key} }",
        'value-type': value_type,
        "#{v_model_type}": input_key,
      })
    end

    def vue_ref
      "select#{'.multiple' if multiple}.#{attr_key}"
    end

    def value_type
      item_value(select_options.first).is_a?(Integer) ? Integer : nil
    end

    def item_value(item)
      item.is_a?(Array) ? item.last : item
    end

    def item_name(item)
      "#{attr_key}_#{item.is_a?(Array) ? item.first : item}"
    end

    def item_disabled(item)
      disabled_values.present? && disabled_values.include?(item_value(item))
    end

    def item_label(item)
      item.is_a?(Array) ? item.first : item
    end

    def v_model_type
      if select_options && item_value(select_options.first).is_a?(Integer) && !multiple
        'v-model.number'
      else
        'v-model'
      end
    end

    def id_for_item(value)
      "#{html_attributes[:id]}_#{value}"
    end

  end
end
