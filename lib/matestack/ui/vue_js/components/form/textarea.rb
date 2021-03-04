module Matestack
  module Ui
    module VueJs
      module Components
        module Form
          class Textarea < Matestack::Ui::VueJs::Components::Form::Base
            vue_name 'matestack-ui-core-form-textarea'

            def response
              div class: 'matestack-ui-core-form-textarea' do
                label input_label, for: id if input_label
                textarea attributes
                render_errors
              end
            end

            def component_id
              "textarea-component-for-#{key}"
            end

            def config
              {
                init_value: init_value,
              }
            end

          end
        end
      end
    end
  end
end