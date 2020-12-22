require_relative '../utils'
require_relative '../has_input_html_attributes'
require_relative '../has_errors'
module Matestack::Ui::Core::Form::Radio
  class Base < Matestack::Ui::Core::Component::Dynamic
    include Matestack::Ui::Core::Form::Utils
    include Matestack::Ui::Core::Form::HasInputHtmlAttributes
    include Matestack::Ui::Core::Form::HasErrors

    requires :key
    optional :multiple, :init, for: { as: :input_for }, label: { as: :input_label }, options: { as: :radio_options }

    def setup
      @component_config[:init_value] = init_value
    end

    def component_id
      "radio-component-for-#{attr_key}"
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

    def render_options
      radio_options.to_a.each do |item|
        input radio_attributes(item)
        label text: item_label(item), for: id_for_item(item_value(item))
      end
    end

    def radio_attributes(item)
      html_attributes.merge(
        attributes: vue_attributes,
        type: :radio,
        id: "#{id_for_item(item_value(item))}",
        name: item_name(item),
        value: item_value(item),
      )
    end

    def vue_attributes
      (options[:attributes] || {}).merge({
        "@change": change_event,
        ref: "select.#{attr_key}",
        'init-value': init_value,
        'v-bind:class': "{ '#{input_error_class}': #{error_key} }",
        'value-type': value_type,
        "#{v_model_type}": input_key,
      })
    end

    def value_type
      item_value(radio_options.first).is_a?(Integer) ? Integer : nil
    end

    def item_value(item)
      item.is_a?(Array) ? item.last : item
    end

    def item_name(item)
      "#{attr_key}_#{item.is_a?(Array) ? item.first : item}"
    end

    def item_label(item)
      item.is_a?(Array) ? item.first : item
    end

    def v_model_type
      if radio_options && item_value(radio_options.first).is_a?(Integer)
        'v-model.number'
      else
        'v-model'
      end
    end

    def id_for_item(value)
      "#{html_attributes[:id] || attr_key}_#{value}"
    end

  end
end
