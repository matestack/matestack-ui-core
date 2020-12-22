require_relative './base'

module Matestack::Ui::Core::Form::Textarea
  class Textarea < Base

    vue_js_component_name "matestack-ui-core-form-textarea"

    def response
      div class: "matestack-ui-core-form-textarea" do
        label text: input_label if input_label
        textarea textarea_attributes
        render_errors
      end
    end

  end
end
