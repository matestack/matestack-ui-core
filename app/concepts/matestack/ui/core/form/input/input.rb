require_relative './base'

module Matestack::Ui::Core::Form::Input
  class Input < Base

    vue_js_component_name "matestack-ui-core-form-input"

    def response
      div class: "matestack-ui-core-form-input" do
        label text: input_label if input_label
        input input_attributes
        render_errors
      end
    end

  end
end
