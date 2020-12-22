require_relative './base'

module Matestack::Ui::Core::Form::Select
  class Select < Base

    vue_js_component_name "matestack-ui-core-form-select"

    def response
      div class: "matestack-ui-core-form-select" do
        label text: input_label if input_label
        select select_attributes do
          render_options
        end
        render_errors
      end
    end

  end
end
