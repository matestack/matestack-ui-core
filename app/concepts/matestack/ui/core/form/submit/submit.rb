require_relative './base'

module Matestack::Ui::Core::Form::Submit
  class Submit < Base

    vue_js_component_name "matestack-ui-core-form-submit"

    def response
      span attributes: submit_attributes do
        yield_components
      end
    end

  end
end
