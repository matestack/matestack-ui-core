require_relative '../utils'
module Matestack::Ui::Core::Form::Textarea
  class Textarea < Matestack::Ui::Core::Textarea::Textarea
    include Matestack::Ui::Core::Form::Utils

    requires :key
    optional :multiple, :init, for: { as: :input_for }, label: { as: :input_label }

    def response
      label text: input_label if input_label
      textarea html_attributes.merge(attributes: vue_attributes)
      span class: 'errors', attributes: { 'v-if': error_key } do
        span class: 'error', text: '{{ error }}', attributes: { 'v-for': "error in #{error_key}" }
      end
    end

    def vue_attributes
      (options[:attributes] || {}).merge({
        'v-model': input_key,
        '@change': "inputChanged('#{attr_key}')",
        "init-value": init_value,
        ref: "input.#{attr_key}",
      })
    end
    
  end
end