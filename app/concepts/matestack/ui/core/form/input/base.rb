require_relative '../utils'
require_relative '../has_input_html_attributes'
require_relative '../has_errors'
module Matestack::Ui::Core::Form::Input
  class Base < Matestack::Ui::Core::Component::Dynamic
    include Matestack::Ui::Core::Form::Utils
    include Matestack::Ui::Core::Form::HasInputHtmlAttributes
    include Matestack::Ui::Core::Form::HasErrors

    requires :key, :type
    optional :multiple, :init, for: { as: :input_for }, label: { as: :input_label }

    def setup
      @component_config[:init_value] = init_value
    end

    def component_id
      "input-component-for-#{attr_key}"
    end

    def input_attributes
      html_attributes.merge(attributes: vue_attributes)
    end

    def input_key
      "$parent.data[\"#{key}\"]"
    end

    def error_key
      "$parent.errors[\"#{key}\"]"
    end

    def change_event
      "inputChanged('#{attr_key}'); #{ "filesAdded('#{attr_key}');" if type == :file }".strip
    end

    def vue_attributes
      (options[:attributes] || {}).merge({
        "@change": change_event,
        ref: "input.#{attr_key}",
        'init-value': init_value,
        'v-bind:class': "{ '#{input_error_class}': #{error_key} }"
      }).merge(
        type != :file ? { "#{v_model_type}": input_key } : {}
      ) # file inputs are readonly, no v-model possible
    end

    def v_model_type
      if type == :number || init_value.is_a?(Integer)
        'v-model.number'
      else
        'v-model'
      end
    end

    def custom_options_validation
      raise "included form config is missing, please add ':include' to parent form component" if @included_config.nil?
    end

    def attr_key
      super + "#{'[]' if multiple && type == :file}"
    end

    private

    def parse_value(value)
      if [true, false].include? value
        value ? 1 : 0
      else
        return value
      end
    end

  end
end
