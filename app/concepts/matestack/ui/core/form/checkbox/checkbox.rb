require_relative './base'

module Matestack::Ui::Core::Form::Checkbox
  class Checkbox < Base

    vue_js_component_name "matestack-ui-core-form-checkbox"

    def response
      div class: "matestack-ui-core-form-checkbox" do
        render_options
        render_errors
      end
    end

  end
end
