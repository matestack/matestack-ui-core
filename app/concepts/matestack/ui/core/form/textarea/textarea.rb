require_relative '../utils'
require_relative '../has_errors'
module Matestack::Ui::Core::Form::Textarea
  class Textarea < Matestack::Ui::Core::Textarea::Textarea
    include Matestack::Ui::Core::Form::Utils
    include Matestack::Ui::Core::Form::HasErrors

    requires :key
    optional :multiple, :init, for: { as: :input_for }, label: { as: :input_label }

    def response
      label text: input_label if input_label
      textarea html_attributes.merge(attributes: vue_attributes)
      render_errors
    end

    def vue_attributes
      (options[:attributes] || {}).merge({
        'v-model': input_key,
        '@change': "inputChanged('#{attr_key}')",
        'v-bind:class': "{ '#{input_error_class}': #{error_key} }",
        "init-value": init_value,
        ref: "input.#{attr_key}",
      })
    end
    
  end
end