require_relative '../utils'
require_relative '../has_input_html_attributes'
require_relative '../has_errors'
module Matestack::Ui::Core::Form::Checkbox
  class Checkbox < Matestack::Ui::Core::Component::Static
    include Matestack::Ui::Core::Form::Utils
    include Matestack::Ui::Core::Form::HasInputHtmlAttributes
    include Matestack::Ui::Core::Form::HasErrors

    requires :key
    optional :value, :false_value, :multiple, :init, for: { as: :input_for }, label: { as: :input_label }, options: { as: :checkbox_options }

    def response
      # multiple values
      if checkbox_options
        checkbox_options.to_a.each do |item|
          input html_attributes.merge(
            attributes: vue_attributes, 
            type: :checkbox,
            id: "#{id_for_item(item_value(item))}",
            name: item_name(item),
            value: item_value(item),
          )
          label text: item_name(item), for: id_for_item(item_value(item))
        end
        # checked/unchecked checkbox
      else 
        form_input type: :hidden, key: key, value: (false_value || 0)
        form_input type: :checkbox, key: key, value: checked_value, id: id_for_item(value)
        label text: input_label, for: id_for_item(value)
      end
      render_errors
    end

    def vue_attributes
      (options[:attributes] || {}).merge({
        "@change": change_event,
        ref: "select.multiple.#{attr_key}",
        'init-value': init_value,
        'v-bind:class': "{ '#{input_error_class}': #{error_key} }",
        'value-type': value_type,
        "#{v_model_type}": input_key,
      })
    end

    def value_type
      item_value(checkbox_options.first).is_a?(Integer) ? Integer : nil
    end

    def item_value(item)
      item.is_a?(Array) ? item.last : item
    end

    def item_name(item)
      item.is_a?(Array) ? item.first : item
    end

    def checked_value
      value || 1
    end

    def v_model_type
      if checkbox_options && checkbox_options.first.is_a?(Integer)
        'v-model.number'
      else
        'v-model'
      end
    end

    def change_event
      "inputChanged('#{attr_key}')"
    end

    def id_for_item(value)
      "#{html_attributes[:id]}_#{value}"
    end

  end
end
