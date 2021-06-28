module Matestack
  module Ui
    module VueJs
      module Components
        module Form
          class Textarea < Matestack::Ui::VueJs::Components::Form::Base
            vue_name 'matestack-ui-core-form-textarea'

            def response
              div class: 'matestack-ui-core-form-textarea' do
                label input_label, ":for": id if input_label
                textarea textarea_attributes
                render_errors
              end
            end

            def textarea_attributes
              attributes
            end

            def component_id
              "textarea-component-for-#{key}"
            end

            def vue_props
              {
                init_value: init_value,
                key: key
              }
            end

          end
        end
      end
    end
  end
end
