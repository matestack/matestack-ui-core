require_relative '../utils'
require_relative '../has_errors'
module Matestack::Ui::Core::Form::Textarea
  class Base < Matestack::Ui::Core::Component::Dynamic
    include Matestack::Ui::Core::Form::Utils
    include Matestack::Ui::Core::Form::HasErrors

    requires :key
    optional :multiple, :init, for: { as: :input_for }, label: { as: :input_label }

    html_attributes :autofocus, :cols, :dirname, :disabled, :form, :maxlength,
      :name, :placeholder, :readonly, :required, :rows, :wrap

    def setup
      @component_config[:init_value] = init_value
    end

    def component_id
      "textarea-component-for-#{attr_key}"
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

    def textarea_attributes
      html_attributes.merge(attributes: vue_attributes)
    end

    def vue_attributes
      (options[:attributes] || {}).merge({
        'v-model': input_key,
        '@change': change_event,
        'v-bind:class': "{ '#{input_error_class}': #{error_key} }",
        "init-value": init_value,
        ref: "input.#{attr_key}",
      })
    end

  end
end
