module Matestack
  module Ui
    module VueJs
      module Components
        module Form
          class Input < Matestack::Ui::VueJs::Components::Form::Base
            vue_name 'matestack-ui-core-form-input'

            def response
              div class: 'matestack-ui-core-form-input' do
                label input_label, for: id if input_label
                input input_attributes
                render_errors
              end
            end

            def component_id
              "input-component-for-#{attribute_key}"
            end

            def input_attributes
              attributes.merge({
                type: ctx.type,
                multiple: ctx.multiple,
                placeholder: ctx.placeholder,
              }).merge(self.options)
            end

            def config
              {
                init_value: init_value,
                key: attribute_key,
              }
            end

          end
        end
      end
    end
  end
end