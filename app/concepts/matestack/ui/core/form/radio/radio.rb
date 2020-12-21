require_relative './base'

module Matestack::Ui::Core::Form::Radio
  class Radio < Base

    vue_js_component_name "matestack-ui-core-form-radio"

    def response
      div class: "matestack-ui-core-form-radio" do
        render_options
        render_errors
      end
    end

  end
end
