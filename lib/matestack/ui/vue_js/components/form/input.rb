module Matestack
  module Ui
    module VueJs
      module Components
        module Form
          class Input < Matestack::Ui::VueJs::Components::Form::Base
            vue_name 'matestack-ui-core-form-input'

            def initialize(*)
              super
              if ctx.type.to_s == "file"
                if !form_context.is_nested_form? && form_context.multipart_option != true
                  raise "File Upload requires `multipart: true` in Form Config"
                end
                if form_context.is_nested_form? && form_context.parent_form_context.multipart_option != true
                  raise "File Upload requires `multipart: true` in Form Config"
                end
              end
            end

            def response
              div class: 'matestack-ui-core-form-input' do
                label input_label, ":for": id if input_label
                input input_attributes
                render_errors
              end
            end

            def component_id
              "input-component-for-#{attribute_key}"
            end

            def input_attributes
              attributes
            end

            def init_value
              return nil if ctx.type.to_s == "file"
              super
            end

            def vue_props
              {
                init_value: init_value,
                key: key,
              }
            end

          end
        end
      end
    end
  end
end
